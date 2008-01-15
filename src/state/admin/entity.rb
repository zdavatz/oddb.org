#!/usr/bin/env ruby
# State::Admin::Entity -- oddb.org -- 08.06.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/entity'

module ODDB
  module State
    module Admin
class Entity < Global
  VIEW = View::Admin::Entity
  def update
    mandatory = [:name]
    preferences = [:name_first, :name_last, :salutation, :address, :plz, :city]
    keys = mandatory + preferences + [ :valid_until, :yus_privileges,
      :yus_groups, :set_pass_1, :set_pass_2, :yus_association ]
    input = user_input(keys, mandatory)
    pass1 = nil
    begin
      pass1 = input[:set_pass_1]
      pass2 = input[:set_pass_2]
      if(pass1 || pass2)
        if(pass1 != pass2)
          err1 = create_error(:e_non_matching_set_pass, :set_pass_1, pass1)
          err2 = create_error(:e_non_matching_set_pass, :set_pass_2, pass2)
          @errors.store(:set_pass_1, err1)
          @errors.store(:set_pass_2, err2)
        end
      end
      unless(error?)
        name = @model.name
        if(@model.is_a?(Persistence::CreateItem))
          @model = @session.user.create_entity(input[:name])
        elsif(input[:name] != name)
          @session.user.rename(name, input[:name])
          name = input[:name]
          @model = @session.user.find_entity(name)
        end
        if(pass1)
          @session.user.set_password(name, pass1)
        end
        preferences.each { |pref|
          @session.user.set_entity_preference(name, pref, input[pref], 'global')
        }
        privs = input[:yus_privileges] || {}
        if((ass_str = input[:yus_association]) \
           && (ass_ptr = Persistence::Pointer.from_yus_privilege(ass_str)) \
           && (ass = ass_ptr.resolve(@session)))
          if(old = @session.app.yus_model(name))
            @session.user.revoke(name, 'edit', old.pointer.to_yus_privilege)
          end
          @session.user.grant(name, 'edit', ass_str)
          @session.user.set_entity_preference(name, 'association', ass.odba_id)
        end
        @session.valid_values(:yus_privileges).each { |privilege|
          action, key = privilege.split('|')
          if(@session.allowed?('grant', action))
            method = privs[privilege] ? :grant : :revoke
            @session.user.send(method, name, action, key)
          end
        }
        groups = input[:yus_groups] || {}
        @model.affiliations.each { |group| 
          unless(groups[group.name])
            @session.user.disaffiliate(name, group.name)
            if(group.name == 'PowerUser')
              @session.user.revoke(name, 'view', 'org.oddb')
            end
          end
        }
        groups.each { |groupname, value|
          @session.user.affiliate(name, groupname)
          time = if(date = input[:valid_until])
                   date = date.next
                   Time.local(date.year, date.month, date.day) - 1
                 end
          if(groupname == 'PowerUser')
            @session.user.grant(name, 'view', 'org.oddb', time)
          end
        }
      end
    rescue Yus::DuplicateNameError => e
      @errors.store(:name, 
                    create_error(:e_duplicate_email, :name, name))
    rescue Yus::YusError => e
      puts e.class, e.message
      puts e.backtrace
      @errors.store(:yus_privileges, 
                    create_error(e.message, :e_yus_error, e.message))
    rescue Exception => e
      puts "something weird happened:"
      puts e.class, e.message
      puts e.backtrace
    end
    self
  end
  def set_pass
    update
  end
end
    end
  end
end
