#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Fachinfo -- oddb.org -- 14.05.2012 -- yasaka@ywesee.com
# ODDB::Fachinfo -- oddb.org -- 24.10.2011 -- mhatakeyama@ywesee.com
# ODDB::Fachinfo -- oddb.org -- 12.09.2003 -- rwaltert@ywesee.com

require 'flickraw'
require 'thread'
require 'util/persistence'
require 'util/language'
require 'util/searchterms'
require 'model/registration_observer'

module ODDB
	class Fachinfo
		class ChangeLogItem
			attr_accessor :email, :time, :chapter, :language
		end
    attr_accessor :links
		include Persistence
		include Language
		include RegistrationObserver
		ODBA_SERIALIZABLE = ['@change_log']
		def add_change_log_item(email, chapter, language)
			item = ChangeLogItem.new
			item.email = email
			item.time = Time.now
			item.chapter = chapter
			item.language = language
			self.change_log.push(item)
			self.odba_store
		end
    def article_codes(expired=true)
      codes = []
      @registrations.collect { |reg|
        next unless reg.fachinfo == self # invalid reference
        if !expired
          next unless(reg.public? and reg.has_fachinfo?)
        end
        reg.each_package { |pac|
          cds = {
            :article_ean13 => pac.barcode.to_s,
          }
          if(pcode = pac.pharmacode)
            cds.store(:article_pcode, pcode)
          end
          if(psize = pac.size)
            cds.store(:article_size, psize)
          end
          if(pdose = pac.dose)
            cds.store(:article_dose, pdose.to_s)
          end
          codes.push(cds)
        }
      }
      codes
    end
    def links
      @links ||= []
			@links.compact.sort_by{|link| link.created}.reverse
    end
		def atc_class
			if(reg = @registrations.first)
				reg.atc_classes.first
			end
		end
		def change_log
			@change_log ||= []
		end
		def company
			if(reg = @registrations.first)
				reg.company
			end
		end
		def company_name
			if(reg = @registrations.first)
				reg.company_name
			end
		end
		def generic_type
			@registrations.each { |reg|
				if(type = reg.generic_type)
					return type
				end
			}
			:unknown
		end
		def localized_name(language=:de)
      name = ''
			if((doc = self.send(language)) && doc.respond_to?(:name))
        name = doc.name.to_s
      end
      name = name_base if(name.empty?)
      name
		end
		def name_base
			if(reg = @registrations.first)
				reg.name_base
			end
		end
		def pointer_descr
			name_base
		end
    def search_text(language)
      ODDB.search_term(self.send(language).indications.to_s)
    end
		def interaction_text(language)
      ODDB.search_term(self.send(language).interactions.to_s)
		end
		def substance_names
			@registrations.collect { |reg|
				reg.substance_names
			}.flatten.uniq
		end
		def unwanted_effect_text(language)
      ODDB.search_term(self.send(language).unwanted_effects.to_s)
		end
    def has_photo?
      registrations.each do |reg|
        reg.packages.each do |pack|
          if pack.has_flickr_photo?
            return true
          end
        end
      end
      return false
    end
    def photos(image_size="Thumbnail")
      # Flickr Image Size (max)
      # "Square"    :  75 x  75 px
      # "Thumbnail" : 100 x 100 px
      # "Small"     : 180 x 240 px
      # "Small320"  : 240 X 320 px
      image_size.capitalize!
      photos = []
      config = ODDB.config
      if config.flickr_api_key.empty? or
         config.flickr_shared_secret.empty?
        return nil
      end
      FlickRaw.api_key = config.flickr_api_key
      FlickRaw.shared_secret = config.flickr_shared_secret
      threads = {}
      mutex = Mutex.new
      registrations.each do |reg|
        reg.packages.each do |pack|
          if id = pack.flickr_photo_id
            unless threads.keys.include?(id)
              threads[id] = Thread.new do
                begin
                  sizes = flickr.photos.getSizes :photo_id => id
                  has_size = false
                  fallback = nil
                  src = nil
                  sizes.each do |size|
                    if size.label == image_size
                      has_size = true
                      src = size.source
                    elsif size.label == 'Thumbnail'
                      fallback = size.source
                    end
                  end
                  if !has_size and fallback
                    src = fallback
                  end
                  if src
                    photo = {
                      :name => pack.name_base,
                      :url  => pack.photo_link,
                      :link => !pack.disable_photo_forwarding,
                      :src  => src,
                    }
                    mutex.synchronize do
                      photos << photo
                    end
                  end
                rescue FlickRaw::FailedResponse => e
                end
              end
            end
          end
        end
      end
      threads.values.each do |thread|
        thread.join
      end
      return nil if photos.empty?
      photos.sort do |a, b| # sort_by size in name
        result = a[:name].gsub(/(\d+)/) { "%04d" % $1.to_i } <=>
                 b[:name].gsub(/(\d+)/) { "%04d" % $1.to_i }
        if result.zero?
          result = a[:name] <=> b[:name]
          if result.zero?
            result = a[:url] <=> b[:url]
          end
        end
        result
      end
    end
  end
	class FachinfoDocument
		include Persistence
		attr_accessor :name, :galenic_form, :composition
		attr_accessor :effects, :kinetic, :indications, :usage
		attr_accessor :restrictions, :unwanted_effects
		attr_accessor :interactions, :overdose, :other_advice
		attr_accessor :date, :iksnrs, :reference, :packages
		attr_accessor :delivery, :distribution, :fabrication
		CHAPTERS = [
			:galenic_form,
			:composition,
			:effects,
			:kinetic,
			:indications,
			:usage,
			:restrictions,
			:unwanted_effects,
			:interactions,
			:overdose,
			:other_advice,
			:delivery,
			:distribution,
			:fabrication,
			#:reference,
			:iksnrs,
			:packages,
			:date,
		]
		def empty?
		end
		def chapter_names
			chapters.select { |chapter|
				respond_to?(chapter) && self.send(chapter)
			}
		end
		def chapters
			self::class::CHAPTERS
		end
		def each_chapter(&block)
			chapter_names.each { |chap|
				if(chapter = self.send(chap))
					block.call(chapter)
				end
			}
		end
		def first_chapter
      chapter = nil
      chapters.find { |chapter| 
        respond_to?(chapter) && chapter = self.send(chapter)
      }
      chapter 
		end
	end
	class FachinfoDocument2001 < FachinfoDocument
		attr_accessor	:contra_indications, :pregnancy
		attr_accessor	:driving_ability, :preclinic
		attr_accessor	:registration_owner, :amzv
		CHAPTERS = [
			:amzv,
			:composition,
			:galenic_form,
			:indications,
			:usage,
			:contra_indications,
			:restrictions,
			:interactions,
			:pregnancy,
			:driving_ability,
			:unwanted_effects,
			:overdose,
			:effects,
			:kinetic,
			:preclinic,
			:other_advice,
			:iksnrs,
			:packages,
			:registration_owner,
			:date,
		]
	end
  class FachinfoLink
    attr_accessor :name, :url, :created
    def initialize
      @name = ''
      @url  = 'http://'
      @created = Time.now.to_s
    end
  end
end	
