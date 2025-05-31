(defproject {{project-name}} "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.11.1"]]
  :repl-options {:init-ns {{project-name}}.core}
  :aliases {"nrepl" {:extra-paths ["test"]
                     :extra-deps {nrepl/nrepl {:mvn/version "1.3.1"}}
                     :jvm-opts ["-Djdk.attach.allowAttachSelf"]
                     :main-opts ["-m" "nrepl.cmdline" "--port" "7888"]}})
