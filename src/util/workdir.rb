#!/usr/bin/env ruby
module ODDB
  # Here we define some helper constants which define where we place files
  # when running the application or the unittest
  # Our expectation is that running all unittest only creates files under data4tests
  # and that non of the checked in files is changes. This is tested in the github test runner
  if defined?(Minitest)
    WORK_DIR = File.expand_path("../../data4tests", File.dirname(__FILE__))
    # TEST_DATA_DIR here we find data we use for teste, eg. xml, xlsx, html or csv files
    TEST_DATA_DIR = File.expand_path("../../test/data", File.dirname(__FILE__))
  else
    WORK_DIR = File.expand_path("../../data", File.dirname(__FILE__))
  end

  # values differ for tests and application
  EXPORT_DIR = File.join(WORK_DIR, "downloads")
  LOG_DIR = File.expand_path(File.join(WORK_DIR, "../log"))
  CSV_DIR = File.join(WORK_DIR, "csv")
  XML_DIR = File.join(WORK_DIR, "xml")

  # Same value for tests and application
  PROJECT_ROOT = File.expand_path("../..", File.dirname(__FILE__))
  RESOURCES_DIR = File.join(PROJECT_ROOT, "doc/resources")
end
