local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }


local Beds, CurrentBed, OnBed = {"v_med_cor_emblmtable"}, nil, false

local createdCamera = 0
ESX = nil
  
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)


-- JUST IF YOU WANT TO DO SOME JOB STUFF (LIKE, MAKE BLIP NOT VISIBLE FOR POLICE)
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    ESX.PlayerData.job = job
end)

-- DISPLAY BLIP
Citizen.CreateThread(function()
  for k,v in pairs(Config.CriminalDoctor) do
  local blip = AddBlipForCoord(v.Blip.Coords)

  SetBlipSprite (blip, v.Blip.Sprite)
  SetBlipDisplay(blip, v.Blip.Display)
  SetBlipScale  (blip, v.Blip.Scale)
  SetBlipColour (blip, v.Blip.Colour)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName('STRING')
  AddTextComponentSubstringPlayerName("Underground Doctor")
  EndTextCommandSetBlipName(blip)
end
end)

-- DRAW 3D TEXT
Citizen.CreateThread(function()
  Citizen.Wait(0)
  function Draw3DText(x, y, z, text)
      local onScreen, _x, _y = World3dToScreen2d(x, y, z)
      local p = GetGameplayCamCoords()
      local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
      local scale = (1 / distance) * 2
      local fov = (1 / GetGameplayCamFov()) * 100
      local scale = scale * fov
      if onScreen then
          SetTextScale(0.35, 0.35)
          SetTextFont(4)
          SetTextProportional(1)
          SetTextColour(255, 255, 255, 215)
          SetTextEntry("STRING")
          SetTextCentre(1)
          AddTextComponentString(text)
          DrawText(_x,_y)
          local factor = (string.len(text)) / 370
          DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
      end
  end
  while true do 
      Citizen.Wait(0)
      local coords = GetEntityCoords(PlayerPedId())
      local ped = PlayerPedId()
      local isHurt = GetEntityHealth(ped) < 200
      for k,v in ipairs(Config.DoctorBed) do
          if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 2.0) then     
              Draw3DText(v.x, v.y, v.z, "~b~[E]~s~ to get help [~g~$" .. Config.toPay .. "~s~]" )
              if IsControlJustReleased(0, 38) and GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 3.0 and isHurt then 
                  local ped = PlayerPedId()
                  TriggerServerEvent("chip_cDoc:takeMoney")
              elseif IsControlJustReleased(0, 38) and not isHurt and CurrentBed ~= nil then
                print("weg")
                exports['mythic_notify']:DoHudText('error', 'You are not hurt!', { ['background-color'] = 'red', ['color'] = '#fff' })
              end
          end
      end
  end
end)

-- BED

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)

		if not OnBed then
			local PlayerPed = PlayerPedId()
			local PlayerCoords = GetEntityCoords(PlayerPed)

			for k,v in pairs(Beds) do
				local ClosestBed = GetClosestObjectOfType(PlayerCoords, 1.5, GetHashKey(v), false, false)

				if ClosestBed ~= 0 and ClosestBed ~= nil then
					CurrentBed = ClosestBed
					break
				else
					CurrentBed = nil
				end
			end
		end
	end
end)


function LoadAnimSet(AnimDict)
	if not HasAnimDictLoaded(AnimDict) then
		RequestAnimDict(AnimDict)

		while not HasAnimDictLoaded(AnimDict) do
			Citizen.Wait(1)
		end
	end
end

function getOnBed() 
  local PlayerPed = PlayerPedId()
			local BedCoords, BedHeading = GetEntityCoords(CurrentBed), GetEntityHeading(CurrentBed)

			LoadAnimSet('missfbi1')
			SetEntityCoords(PlayerPed, BedCoords)
			SetEntityHeading(PlayerPed, (BedHeading+180))

			TaskPlayAnim(PlayerPed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
			OnBed = true
end


-- THE ACTUAL "GETTING HELP THING" THING

RegisterNetEvent("chip_cDoc:getHelp")
AddEventHandler("chip_cDoc:getHelp", function()
  getOnBed()
  local ped = PlayerPedId()
  createCameraScene()
  TriggerEvent("mythic_progressbar:client:progress", {
    name = "unique_action_name",
    duration = 20000,
    label = "You are being treated...",
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }
}, function(status)
    if not status then
      local ped = PlayerPedId()
      SetEntityHealth(ped, 200)
    end
end)
  Citizen.Wait(20000)
  closeCameraScene()
  ClearPedTasks(ped)
end)



function createCameraScene()
  local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
	SetCamCoord(cam, -1401.21, -436.76, 38.01)
	SetCamRot(cam, 180.0, 180.0, -10.0, 2)
	RenderScriptCams(true, true, 100, true, true)
  createdCamera = cam
end

function closeCameraScene()
	DestroyCam(createdCamera, 0)
	RenderScriptCams(0, 0, 100, 1, 1)
	createdCamera = 0
	ClearTimecycleModifier("scanline_cam_cheap")
  SetFocusEntity(GetPlayerPed(PlayerId()))
end
