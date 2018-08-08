[![Build Status](https://travis-ci.org/ReadyTalk/kamailio-docker.svg?branch=master)](https://travis-ci.org/ReadyTalk/kamailio-docker)

# Kamailio-Docker

Runs kamailio in a docker container.  Has several options for configuring kamailio, and an example config.

## Config

This config is designed to run as a proxy for webrtc clients to talk to traditional sip endpoints.  

The Config has been split into multipule files to allow for easier overriding of certain configurations by mounting files during docker startup.
### Layout

Current the config is all contaned in `/etc/kamailio/` and is broken up like this:
* kamailio.cfg -- contains nothing but includes of the other files.  This will be what the kamailio process will load first.
  * defines.cfg -- contains all set `#!define` populated as environment variables that start with `KAM_DEFINE_`.
  * vars.cfg -- contains all set `#!substdef`populated as environment variables that start with `KAM_` and do not have `DEFINE_`.
  * logging.cfg -- contains the logging options, default is to log to stderr with debug level=2.
  * listeners.cfg -- contains the default setup of UDP/TCP/TLS listeners.
  * basic_options.cfg -- contains the basic options used by kamailio, memory sizes, buffer sizes, tls options (if enabled).  
  * extra_options.cfg -- This is an empty file that loads after basic_options, this can be used to set other options for kamailio (not its modules that is done later).
  * modules_load.cfg -- This loads the default list of modules and any modules that can be enabled with a `#!define`.
  * modules_load_extra.cfg -- This is an empty file to load any other modules that are needed/
  * modules_config.cfg -- This loads the default settings for all modules that where enabled.
  * modules_config_extra.cfg -- This is an empty file that loads after modules_config to allow cutom configuration of modules.
  * routes.cfg -- This provides the includes associated with routing.
    * routes/MAIN.cfg -- provides the main request_route block.
    * routes/AUTH.cfg -- provides the AUTH route (default behavior is 403 on register).
    * routes/PRESENCE.cfg -- provides the handing of PRESENCE packets route (default is not supported 404 returned).
    * routes/REQINIT.cfg -- provides the REQINIT route used for sip checking/rejecting.
    * routes/RELAY.cfg -- provides the ROUTE route used currently to t_relay() requests.
    * routes/LOADBALANCE.cfg -- provides the LOADBALANCE route and its needed MANAGE_FAILURE route.  
    * routes/HOMER_SECURITY_CHECKS.cfg -- provides the HOMER_SECURITY_CHECKS route if it is enabled.
    * routes/EVENTS.cfg -- provideds default event handlers for xhttp, websockets, and htable.
    
### Provided Options
There are quite a few options provided by default as environtment variables.  You can always just override config where needed as well, but the environment variables are setup to provide some basic functionailty w/o having to do that.

Here is the list of defines:
* KAM_DEFINE_DB_MOD_FILE -- Sets the database module to use.  Default is `db_sqlite.so` but mysql can also be used with `db_mysql.so`
* KAM_DEFINE_DBURL -- Sets the url to the database.  Default is `sqlite:////etc/kamailio/kamailio.sqlite`
* KAM_DEFINE_WITH_UDP -- Enables the UDP kamailio port.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_TCP -- Enables the TCP kamailio port.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_TLS -- Enables the TLS kamailio port.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_WEBSOCKETS -- Enables the use of websockets in kamailio.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_USRLOCDB -- Enables USRLOCDB module in kamailio.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_ANTIFLOOD -- Enables the ANTIFLOOD module in kamailio.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_LOADBALANCE -- Enables the DISPATCHER module in kamailio.  Default is `true`, set to `false` to disable.
* KAM_DEFINE_WITH_DEBUG -- Enables Debug logging in kamailio.  Default is `false`, set to `true` to enable.
* KAM_DEFINE_WITH_STATSD -- Enables STATSD module in kamailio.  Default is `false`, set to `true` to enable.
* KAM_DEFINE_TLS_CONFIG_PATH -- Sets the TLS file config path. Default is `/etc/kamailio/tls_mod.cfg`.

Not all config can use defines, some times we have to substitute parts of the config below are the variables that do that:
* KAM_INT_IP -- Sets the internal IP address to use for kamailio. Default is `0.0.0.0`.
* KAM_EXT_IP -- Sets the external IP to advertize to sip hosts. Default is `127.0.0.1`. (probably should be overriden).
* KAM_UDP_PORT -- Sets the default UDP port to listen on for sip traffic. Default is `5060`. 
* KAM_TCP_PORT -- Sets the default TCP port to listen on for sip traffic. Default is `5060`.
* KAM_TLS_PORT -- Sets the default TLS port to listen on for sip traffic. Default is `5061`.
* KAM_STATSD_HOST -- Sets the host for statsd to connect to. Default is `localhost`.
* KAM_STATSD_PORT -- Sets the port of the statd listener to send traffic too. Default is `9125`.
* KAM_SHM_FORCE_ALLOC -- Sets if shared memory is allocated up front or lazily. Default is `yes`.
* KAM_SHM_MEM_SIZE -- Sets the max shared memory that is used by kamailio. Default is `128`.
* KAM_KAM_TCP_TIMEOUT -- Sets the max in seconds an idle TCP connection stay connected. Default is `300`.

Since this image is mostly made to use Kamailio as a loadbalancer there is an envinronment variable that can be set to add routes to the local sqlite db:
* KAM_DISPATCHER_ROUTES -- Sets the routes that this kamailio instance will ping/talk to.  Use `,` to seperate the list of servers.

#### env.sh
Since sometime environment variables are hard to set/get/use all the above variables can be set in a file, If you override the `/env.sh` file.  It is sourced as part of the kamailio startup so any `KAM_` values set in there will be injected into the kamailio config.

