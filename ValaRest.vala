/**
 * VALA-REST
 * https://github.com/jbuchbinder/vala-rest
 *
 * vim: tabstop=4:softtabstop=4:shiftwidth=4:expandtab
 */

using Gee;
using GLib;
using Posix;
using Soup;

namespace ValaRest {

    /**
     * Class to contain REST server mappings.
     */
    public class RestMapping {
        public string mapping { get; set; }
        public RestObject obj { get; set; }
    } // end class RestMapping

    public interface RestObject : GLib.Object {

        public string get_mapping ( RestObject obj ) {
            foreach ( RestMapping m in mappings ) {
                if (m.obj == obj) {
                    return m.mapping;
                }
            } // end foreach mappings
            return "";
        } // end get_mapping

        public void handler (Soup.Server server, Soup.Message msg,
                string path, GLib.HashTable? query, Soup.ClientContext client) {
            string subpath = path.replace(get_mapping(this), "");
            string? id = (subpath != null && subpath.has_prefix("/")) ? subpath.substring(1) : null;
            if (msg.method == "GET") {
                // GET: retrieve record
            } else if (msg.method == "POST") {
                // POST: new record
            } else if (msg.method == "DELETE") {
                // DELETE: remove record
                if ( id != null ) {
                    delete_object( id );
                }
            } else {
                msg.set_response (RESPONSE_TYPE, Soup.MemoryUse.COPY, ERROR_RESPONSE.printf("Invalid method.").data);
            }
        } // end handler

        /**
         * Delete an object by primary key.
         */
        public abstract void delete_object ( string pk );

        /**
         * Deserialize an object from a JSON string.
         */
        public abstract RestObject deserialize ( string data );

        /**
         * Serialize a JSON string from an object.
         */
        public abstract string serialize ( RestObject obj );

    } // end interface RestObject

    public static const string RESPONSE_TYPE = "text/json";
    public static const string ERROR_RESPONSE = "{\"status\":\"error\",\"message\":\"%s\"}";

    protected Soup.Server server = null;
    protected ArrayList<RestMapping> mappings = null;

    public class Server {

        public Server () {
            mappings = new ArrayList<RestMapping>();
        } // end constructor

        /**
         * Add server object mapping. "mapping" should start with a slash
         * and represent an absolute path for this object.
         */
        public void add_mapping ( string mapping, RestObject obj ) {
            RestMapping m = new RestMapping();
            m.mapping = mapping;
            m.obj = obj;
            mappings.add( m );
        } // end add_mapping

        public void default_handler (Soup.Server server, Soup.Message msg, string path,
                GLib.HashTable? query, Soup.ClientContext client) {
            StringBuilder sb = new StringBuilder();
            sb.append("""
                <html>
                <head>
                <title>REST Server</title>
                </head>
                <body>
                <ul>REST Mappings
            """);
            foreach ( RestMapping m in mappings ) {
                sb.append("<li>" + m.mapping + "</li>");
            } // end foreach mappings
            sb.append("""
                </ul>
                </body>
                </html>
            """);

            msg.set_response ("text/html", Soup.MemoryUse.COPY, sb.str.data);
        } // end default_handler

        public async void start ( int port ) {
            server = new Soup.Server( Soup.SERVER_PORT, port );
            server.add_handler( "/", default_handler );
            foreach ( RestMapping m in mappings ) {
                server.add_handler( m.mapping, m.obj.handler );
            } // end foreach mappings
            server.run();
        } // end start

    } // end Server

} // end namespace ValaRest

