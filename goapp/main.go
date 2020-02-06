package main
// WORST HTTP SERVER EVER
import (
    "fmt"
	"strings"
    "log"
    "os"
	"net/http"
	"github.com/keimoon/gore"
	"github.com/joho/godotenv"
)

func main() {
	// Load env file
	err := godotenv.Load()
	if err != nil {
	  log.Fatal("Error loading .env file")
	}
	// get listening ip and port from env file
	HTTP_IP := os.Getenv("HTTP_IP")
	HTTP_PORT := os.Getenv("HTTP_PORT")

    http.HandleFunc("/", HelloServer)
	fmt.Println("Running HTTP Server on port",HTTP_PORT)
	http.ListenAndServe( HTTP_IP+":"+HTTP_PORT, nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {

	if strings.Contains(r.URL.Path,".") {
		// if theres a dot in url response will be 404
		http.Error(w,http.StatusText(http.StatusNotFound), http.StatusNotFound)
	}else{
		// Otherwise 200 with redis count
		REDIS_IP := os.Getenv("REDIS_IP")
		REDIS_PORT := os.Getenv("REDIS_PORT")
		conn, err := gore.Dial(REDIS_IP + ":" + REDIS_PORT)
	
		if err != nil {
			log.Fatal("Error Connecting to Redis")
		}
		// if URL hast flush in it delete redis key
		if strings.Contains(r.URL.Path,"flush") {
			gore.NewCommand("DEL","visit").Run(conn)
		}
		// get visit from redis
		rep, _ := gore.NewCommand("GET", "visit").Run(conn)
		m, _ := rep.Integer()
		// write some useless data in browser
		w.Header().Set("Content-Type","text/html")
		fmt.Fprintf(w,"page was visited %d times!</br>",m)
		fmt.Fprintf(w,"client_ip:%s</br>",r.RemoteAddr)
		fmt.Fprintf(w,"</br></br></br>Request data <pre>")
	
		for k, v := range r.Header { 
			fmt.Fprintf(w,"%s: %s</br>",k,v)
		}

		fmt.Fprintf(w,"</pre>")
		m+=1
		// inceremnt visit counter and close redis connection
		// not doing a pool or worker since i like to do a stress test
		gore.NewCommand("SET","visit", m).Run(conn)		
		defer conn.Close()
	}
}