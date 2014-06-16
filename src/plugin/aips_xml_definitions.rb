# Definitions for the sax-machine to parse the Aips*.xml
# Preparations.xml

require 'sax-machine'

class SectionContent
  include SAXMachine
  attribute :id
  element :title
end

class SectionsContent
  include SAXMachine
  elements :section, :class => SectionContent
end

class MedicalInformationContent
  include SAXMachine
  attribute :type
  attribute :version
  attribute :lang
  attribute :safetyRelevant
  element :title
  element :authHolder
  element :atcCode
  element :substances
  element :authNrs
  element :remark
  element :style
  element :content
  element :sections, :class => SectionsContent
end

class MedicalInformationsEntry
  include SAXMachine
  elements :medicalInformation, :lazy => true, :as => :medicalInformations, :class => MedicalInformationContent
end
