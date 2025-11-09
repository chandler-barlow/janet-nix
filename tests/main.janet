(use spork/json)
(use sh)

# prints {"foo":"bar"} to std out
(defn main [& args]
  ($ echo (encode @{"foo" "bar"})))
