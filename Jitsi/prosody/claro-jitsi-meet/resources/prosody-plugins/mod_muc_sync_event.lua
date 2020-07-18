local jid = require "util.jid";
local iam_url = module:get_option_string("iam_url");
local iam_secret = module:get_option_string("iam_secret");
local http_request = require "http.request"
local json = require "util.json";

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

log("debug", "[AMX DEBUG] Initializing sync events");

-- Read general options
-------------------------------------------------

local http_timeout = 30;
local excluded_room = "org.jitsi";

if iam_url == nil or iam_secret == nil then
    log("error", "No configuration provided for IAM sync process");
    return;
end

-- Configure MUCs
-------------------------------------------------

local muc_component_host = module:get_option_string("muc_component");

if muc_component_host == nil then
    log("error", "No muc_component specified. No muc to operate on!");
    return;
end

local waiting_muc_component_host = module:get_option_string("waiting_muc_component");

if waiting_muc_component_host == nil then
    log("error", "No lobby_muc_component specified. No muc to operate on!");
    return;
end

log("info", "[AMX DEBUG] Starting sync events for %s", muc_component_host);

local waiting_muc_service;
local main_muc_service;

-- Listen for main muc events
-------------------------------------------------

function destroy_waiting_room(roomName)
    if waiting_muc_service then
        local waiting_room_jid = roomName .. '@' .. waiting_muc_component_host;
        local waiting_room = waiting_muc_service.get_room_from_jid(waiting_room_jid)
        if waiting_room then
             log("info", "[AMX DEBUG] Finishing waiting room for conference: %s", roomName);
             --waiting_room:clear();
             waiting_room:destroy();
             log("info", "[AMX DEBUG] Finished waiting room for conference: %s", roomName);
        else
            log("info", "[AMX DEBUG] No waiting room found for: %s", waiting_room_jid);
        end
    else
        log("info", "[AMX DEBUG] No waiting room for conference: %s", roomName);
    end
end

function room_created(event, waiting)
    local room = event.room;
    local roomName =  jid.node(event.room.jid);
    if not string.starts(roomName, excluded_room) then
        log("info", "[AMX DEBUG] Conference started: %s | waiting: %s", roomName, waiting);
        local requestUrl = iam_url .. "v1/business/conference/sync";
        local data = {
           ["event"] = "CONFERENCE_CREATED",
           ["secret"] = iam_secret,
           ["waiting"] = waiting,
           ["data"] = roomName,
        };
        local req = http_request.new_from_uri(requestUrl)
        local req_data = json.encode(data)
        req.headers:upsert(":method", "POST")
        req.headers:upsert("content-type", "application/json")
        req:set_body(req_data)
        local headers, stream = assert(req:go(http_timeout))
        local body = assert(stream:get_body_as_string())
        if headers:get ":status" ~= "200" then
            log("info", "[AMX DEBUG] Sync event error: %s", body);
        else
            log("info", "[AMX DEBUG] Sync event finished: %s", body);
            if not waiting then 
                destroy_waiting_room(roomName)
            end
        end
    end
end

-- Conference ended, send speaker stats
function room_destroyed(event, waiting)
    local room = event.room;
    local roomName =  jid.node(event.room.jid);
    if not string.starts(roomName, excluded_room) then
        log("debug", "[AMX DEBUG] Conference destroyed: %s | waiting: %s", roomName, waiting);
            local requestUrl = iam_url .. "v1/business/conference/sync";
        local data = {
           ["event"] = "CONFERENCE_DESTROYED",
           ["secret"] = iam_secret,
           ["waiting"] = waiting,
           ["data"] = roomName,
        };
        local req = http_request.new_from_uri(requestUrl)
        local req_data = json.encode(data)
        req.headers:upsert(":method", "POST")
        req.headers:upsert("content-type", "application/json")
        req:set_body(req_data)
        local headers, stream = assert(req:go(http_timeout))
        local body = assert(stream:get_body_as_string())
        if headers:get ":status" ~= "200" then
            log("info", "[AMX DEBUG] Sync event error: %s", body);
        else
            log("info", "[AMX DEBUG] Sync event finished: %s", body);
        end
    end
end

-- Bootstrap mucs hooks
-------------------------------------------------

function process_host_module(name, callback)
    local function process_host(host)
        if host == name then
            callback(module:context(host), host);
        end
    end

    if prosody.hosts[name] == nil then
        module:log('debug', '[AMX DEBUG] No host/component found, will wait for it: %s', name)
        -- when a host or component is added
        prosody.events.add_handler('host-activated', process_host);
    else
        process_host(name);
    end
end

-- Main muc hooks
-------------------------------------------------
function process_main_muc_loaded(main_muc, host_module)
    module:log('debug', '[MX DEBUG] main muc loaded');
    main_muc_service = main_muc;
    host_module:hook("muc-room-created", function (event)
        room_created(event, false)
    end, -1);
    host_module:hook("muc-room-destroyed", function (event)
        room_destroyed(event, false)
    end, -1);
end


process_host_module(muc_component_host, function(host_module, host)
    -- lobby muc component created
    module:log('info', '[AMX DEBUG] Main muc component loaded %s', host);
    local muc_module = prosody.hosts[host].modules.muc;
    if muc_module then
        process_main_muc_loaded(muc_module, host_module);
    else
        module:log('info', '[AMX DEBUG] Will wait for main muc to be available');
        prosody.hosts[host].events.add_handler('module-loaded', function(event)
            if (event.module == 'muc') then
                process_main_muc_loaded(prosody.hosts[host].modules.muc, host_module);
            end
        end);
    end
end);


-- Main muc hooks
-------------------------------------------------
function process_waiting_muc_loaded(waiting_muc, host_module)
    module:log('debug', '[MX DEBUG] waiting muc loaded');
    waiting_muc_service = waiting_muc;
    host_module:hook("muc-room-created", function (event)
        room_created(event, true)
    end, -1);
    host_module:hook("muc-room-destroyed", function (event)
        room_destroyed(event, true)
    end, -1);
end


process_host_module(waiting_muc_component_host, function(host_module, host)
    -- lobby muc component created
    module:log('info', '[AMX DEBUG] Waiting muc component loaded %s', host);
    local muc_module = prosody.hosts[host].modules.muc;
    if muc_module then
        process_waiting_muc_loaded(muc_module, host_module);
    else
        module:log('info', '[AMX DEBUG] Will wait for waiting muc to be available');
        prosody.hosts[host].events.add_handler('module-loaded', function(event)
            if (event.module == 'muc') then
                process_waiting_muc_loaded(prosody.hosts[host].modules.muc, host_module);
            end
        end);
    end
end);

