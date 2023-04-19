{ hosts, pkgs, ... }:
let
  script = ''
    <!DOCTYPE html>
    <html>

    <head>
        <title>📺</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">

        <script defer type="text/javascript">
            let el;
            const hosts = ${builtins.toJSON hosts};
            async function run() {
                try {
                    let content = "";
                    for (const host of hosts) {
                        const res = await fetch("https://" + host + ".greaka.de/viewers");
                        let count;
                        if (res.ok) {
                            const data = await res.json();
                            count = data.response.totalConnections;
                        } else {
                            count = "offline";
                        }
                        content += '<div class="host"><span class="name">' + host + '</span><span class="count">' + count + '</span></div>';
                    }
                    el.innerHTML = content;
                } catch {
                    el.innerText = "error";
                } finally {
                    window.setTimeout(run, 1000);
                }
            }

            function load() {
                el = document.getElementById("number");
                run();
            }
        </script>
        <style>
        body {
            font-size: 10vh;
            color: #eee;
            background-color: #333;
            height: 80vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #number {
            display: grid;
            grid-template-columns: auto 1fr;
            column-gap: 10vw;
        }

        .host {
            display: contents;
            padding: 2vh 2vh 0 2vh;
            border: solid #5cc 1px;
            border-radius: 50px;
            text-align: center;
            margin: 20px;
        }

        .name:after {
            content: ": ";
        }
        </style>
    </head>

    <body onload="load()">
        <div id="number"></div>
    </body>

    </html>
  '';
in {
  services.nginx.virtualHosts."stream.greaka.de".locations."/all" = {
    priority = 990;
    root = pkgs.writeTextFile {
      name = "all-html";
      text = script;
      destination = "/all/index.html";
    };
    index = "index.html";
  };
}
