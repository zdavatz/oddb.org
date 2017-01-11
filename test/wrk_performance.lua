-- To be used with https://github.com/wg/wrk, typical call is wrk -t30 -c50 -d180s --script=test/wrk_performance.lua http://oddb-ci2.dyndns.org
-- Care is taken to implement the following features
--  * show visited path and time taken for it (varies greatly!)
--  * use a typical mix of visited
--  * thread nr 2 sleeps 2 seconds after each request (just to be sure, that this thread must have less requests
--  * response with status != 200 abort the script
--  * response which contains 'Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden.' or 'Abfragebeschränkung' abort the script
--  * must use patched test site which
--  ** returns '' in the method to_html of src/view/google_ad_sense.rb
--  ** returns false in the method limited? of src/state/global.rb
-- TODO: cleanup correctly, because running it several time the server crashes with an error message like
---      With 2007 sessions we have more than 2000 sessions. Exiting
-- local dbg = require("test/debugger") -- uncomment this line if you want to debug this script
local counter = 1
local path = 'undefined'
local start_time = 'undefined'
local threads = {}
local posted = false

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   responses = 0
   local msg = "thread %d created"
end

not_yet = {

}
paths_to_visit = {
        '/de/gcc/show/fachinfo/00699/diff/11.01.2017',
        -- '/de/gcc/company/ean/7601001331709',
        '/de/gcc/search/zone/drugs/search_query/Teva/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/Novartis/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/Sandoz/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/iscador U/search_type/st_combined&#best_result',
        '/de/gcc/search/zone/drugs/search_query/Aspirin/search_type/st_combined&#best_result',
        '/de/gcc/search/zone/drugs/search_query/Paracetamol/search_type/st_oddb#best_result',
        '/de/gcc/fachinfo/reg/66292',
        '/de/gcc/fachinfo/reg/66165',
        '/de/gcc/fachinfo/reg/66096',
        '/de/gcc/fachinfo/reg/66073',
        '/de/gcc/fachinfo/reg/66072',
        '/de/gcc/fachinfo/reg/66009',
        '/de/gcc/fachinfo/reg/65967',
        '/de/gcc/fachinfo/reg/65964',
        '/de/gcc/fachinfo/reg/65962',
        '/de/gcc/fachinfo/reg/65952',
        '/de/gcc/fachinfo/reg/65908',
        '/de/gcc/fachinfo/reg/65899',
        '/de/gcc/fachinfo/reg/65890',
        '/de/gcc/fachinfo/reg/65883',
        '/de/gcc/fachinfo/reg/65881',
        '/de/gcc/fachinfo/reg/65866',
        '/de/gcc/fachinfo/reg/65854',
        '/de/gcc/fachinfo/reg/65850',
        '/de/gcc/fachinfo/reg/65822',
        '/de/gcc/search/zone/drugs/search_query/Teva/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/Novartis/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/Sandoz/search_type/st_company',
        '/de/gcc/search/zone/drugs/search_query/iscador U/search_type/st_combined&#best_result',
        '/de/gcc/search/zone/drugs/search_query/Aspirin/search_type/st_combined&#best_result',
        '/de/gcc/search/zone/drugs/search_query/Paracetamol/search_type/st_oddb#best_result',
}

request = function()
  requests = requests + 1
  path = paths_to_visit[((requests + id*5) % table.getn(paths_to_visit))+ 1]
  start_time = os.time()
  return wrk.format(nil, path)
end

function response(status, headers, body)
   local msg = "body %s\nunexpected status %d for thread %d after %d requests with path %s"
   local okay = "%02d:%02d:%02d thread %d path %s took %s second"
   local not_found =  'Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden.'
   local limit = 'Abfragebeschränkung'
   if (string.find(body, limit)) then
      print(msg:format("mit " .. limit, status, id, requests, path))
      print(limit)
      print(headers["Set-Cookie"])
      os.exit(status)
   end
   if (string.find(body, not_found)) then
      print(msg:format(body, status, id, requests, path))
      print(not_found)
      os.exit(status)
   end
   if (status == 200) then
      local diff_time = os.difftime(os.time(), start_time)
      local time = os.date("*t")
      print(okay:format(time.hour, time.min, time.sec, id, path, diff_time))
   else
      print(msg:format(body, status, id, requests, path))
      os.exit(status)
   end
   if (id == 2) then os.execute("sleep 1") end
   responses = responses + 1
end

function done(summary, latency, requests, counter)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests and got %d responses"
      print(msg:format(id, requests, responses))
   end
end
