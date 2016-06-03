function trim (s)
  return (s:gsub ("^%s*(.-)%s*$", "%1"))
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        return print_r(arr, 0)
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."___\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": <br>"..print_r(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."<br>"
        end
    end
    return str
end

local function connect (conn, data)
   local query_data

   conn:on ("receive",
      function (cn, req_data)
         query_data = get_http_req (req_data)
         print (query_data["METHOD"] .. " " .. " " .. query_data["User-Agent"]);
         
         cn:send ("HTTP/1.1 200 OK \r\n");
         cn:send ("Server: NodeMCU on ESP8266\r\n");
         cn:send ("Content-Type: text/html; charset=UTF-8\r\n\r\n");
         
         cn:send ("<h3>Hello World from ESP8266 and NodeMCU!!</h3>")
         cn:send ("<p>Query data</p>")
         cn:send (print_r(query_data))
         cn:close ( )
      end)
end

function get_http_req (instr)
   local t = {}
   local first = nil
   local key, v, strt_ndx, end_ndx

   for str in string.gmatch (instr, "([^\n]+)") do
      -- First line in the method and path
      if (first == nil) then
         first = 1
         strt_ndx, end_ndx = string.find (str, "([^ ]+)")
         v = trim (string.sub (str, end_ndx + 2))
         key = trim (string.sub (str, strt_ndx, end_ndx))
         t["METHOD"] = key
         t["REQUEST"] = v
      else -- Process and reamaining ":" fields
         strt_ndx, end_ndx = string.find (str, "([^:]+)")
         if (end_ndx ~= nil) then
            v = trim (string.sub (str, end_ndx + 2))
            key = trim (string.sub (str, strt_ndx, end_ndx))
            t[key] = v
         end
      end
   end
   return t
end

print("Ready to start soft ap")
print("ssid = 'esp8266'");
print("pwd = '12345678'");

wifi.ap.config({
    ssid = 'esp8266',
    pwd = '12345678'
});

wifi.ap.setip({
    ip="192.168.1.1",
    netmask="255.255.255.0",
    gateway="192.168.1.1"
});

wifi.setmode(wifi.SOFTAP)
wifi.ap.dhcp.start()

collectgarbage();

print("Soft AP started")
print("Heep:(bytes)"..node.heap());
print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());

svr = net.createServer (net.TCP, 30);
svr:listen (80, connect);

