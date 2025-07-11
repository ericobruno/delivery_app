pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "controllers", to: "controllers/index.js"
pin "sortablejs", to: "https://esm.sh/sortablejs@1.15.6" 