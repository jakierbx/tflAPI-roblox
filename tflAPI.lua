--[[

▀█▀ █▀▀ █   ▄▀▄ █▀█ ▀█▀ 
 █  █▀  █▄▄ █▀█ █▀▀ ▄█▄ 

To interact with the Transport for London API, and collect data from air quality reports
to line status

Author: lxbical
Version: v1.0

Please remember to enable HTTP requests, otherwise you will be returned with an error.

█▀▄ █▀█ █▀▀ █ █ █▄ ▄█ █▀▀ █▄ █ ▀█▀ ▄▀▄ ▀█▀ ▀█▀ █▀█ █▄ █ 
█▄▀ █▄█ █▄▄ █▄█ █ ▀ █ ██▄ █ ▀█  █  █▀█  █  ▄█▄ █▄█ █ ▀█ 

https://github.com/jakierbx/tflAPI-roblox/wiki

--

For help, suggestions or reports, make a pull request or issue report on the github page at
https://github.com/jakierbx/tflAPI-roblox/

--]]

local httpService = game:GetService("HttpService")
local dataResponse = {}

local tflAPI = {}

function tflAPI.MakeHttpRequest(link)

            local response = httpService:RequestAsync({
                  Url = link,
                  Method = "GET"
            })

            local data = httpService:JSONDecode(response.Body)
      
      return(data)
end


function tflAPI.GetTubeOrBusLineStatus(line)
      
      local link = "https://api.tfl.gov.uk/Line/"..line.."/Status"
      local responseback = tflAPI.MakeHttpRequest(link)

      if responseback[1].lineStatuses == nil then
            return("Invalid")
      end

      local reason = responseback[1].lineStatuses[1].reason
      local status = responseback[1].lineStatuses[1].statusSeverityDescription

      if reason == nil then
            dataResponse = {
                  Status = status,
                  Reason = status,
            }      

      elseif reason ~= nil then
            dataResponse = {
                  Status = status,
                  Reason = reason,
            }
      end

      return(dataResponse)
end

function tflAPI.GetStopIdFromName(query, tube)

      if tube == true then
            query = query.." Underground Station"
      end
      
      local link = "https://api.tfl.gov.uk/StopPoint/Search/"..query
      local responseback = tflAPI.MakeHttpRequest(link)

      local amount = responseback.total
      dataResponse = {}

      for i = 1, amount, 1 do
            dataResponse[i] = {
                  StationId = responseback.matches[i].id,
            }

      end

      return(dataResponse)


end

function tflAPI.GetTrainArrivalTimes(line, stationid, direction)

      local responseback = tflAPI.MakeHttpRequest("https://api.tfl.gov.uk/Line/"..line.."/Arrivals/"..stationid.."?"..direction)
      local total = #responseback

      dataResponse = {}

      for i = 1, total, 1 do
            dataResponse[i] = {
                  currentlyAt = responseback[i].currentLocation,
                  destinationStation = responseback[i].towards,
                  trainId = responseback[i].vehicleId,
                  arrivesInSeconds = responseback[i].timeToStation,
                  arrivesInMinutes = math.floor(responseback[i].timeToStation / 60 + 0.5), 
                  positionInQueue = i
            }
      end

      return(dataResponse)
end

function tflAPI.GetBusArrivalTimes(stopid)
      
      local responseback = tflAPI.MakeHttpRequest("https://api.tfl.gov.uk/StopPoint/"..stopid.."/arrivals")
      local total = #responseback

      dataResponse = {}

      for i = 1, total, 1 do
            dataResponse[i] = {
                  destinationStation = responseback[i].destinationName,
                  arrivesInSeconds = responseback[i].timeToStation,
                  arrivesInMinutes = math.floor(responseback[i].timeToStation / 60 + 0.5), 
                  busRoute = responseback[i].lineName,
                  positionInQueue = i
            }
      end


      return(dataResponse)
end

function tflAPI.GetLiftDisruptions(allstations, certainstationid)

      local responseback = tflAPI.MakeHttpRequest("https://api.tfl.gov.uk/Disruptions/Lifts")
      local total = #responseback

      dataResponse = {}

      for i = 1, total, 1 do
            dataResponse[i] = {
                  message = responseback[i].message,
                  stopName = responseback[i].stopPointName,
            }

            if certainstationid == responseback[i].stopPointName and allstations ~= true then 
                  return(dataResponse[i])
            end

      end

      return(dataResponse)
end

function tflAPI.GetAirQualityReport()
      
      local responseback = tflAPI.MakeHttpRequest("https://api.tfl.gov.uk/AirQuality")
      dataResponse = {}

      dataResponse = {

            OverallSummary = responseback.currentForecast[1].forecastSummary,
            ShortTerm = responseback.currentForecast[1].forecastBand,
            MalformedReport = responseback.currentForecast[1].forecastText,
      }

      return(dataResponse)
end

return tflAPI
