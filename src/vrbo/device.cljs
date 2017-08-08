(ns vrbo.device
  (:require
   [reagent.core :as reagent]
   ))

;; START DEMO 

(defonce clicks (reagent/atom 0))

(defn click-action
  []
 ) 

(defn demo-comp
  []
  [:div
  [:span (str "Demo counter " @clicks)]
  [:input {:type "button" :value "Click" 
            :on-click #(swap! clicks inc)}]]
  )

;; END DEMO

(defn main-comp
  []
  (demo-comp))

(defn mount-root
  "mounts root reagent component"
  []
  (reagent/render [main-comp] (.getElementById js/document "device-root")))

(defn initialize-state
  []
   (reset! clicks 0)
  )

(defn init!
  "gets called to initialize whole spa"
  []
  (initialize-state)
  (mount-root))
