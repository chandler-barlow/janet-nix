(declare-project 
  :name "test"
  :description "testing that we can build jpm project"
  :dependencies [ "spork" "https://github.com/andrewchambers/janet-sh.git"])

(declare-executable 
  :name "test-exe"
  :entry "main.janet")
