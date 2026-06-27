local p = Player
local a = Ai
local o = Object
local h = Hud
local e = Event
local G = _G
G.WD = G.WD or {v=0,k=0,e={},a=false}
G.WD.p = _MODULES.vz.MrxFactionManager._tFactions.Pmc.uGuid
G.WD.g = _MODULES.vz.MrxFactionManager._tFactions.Gur.uGuid
local wd = G.WD

wd.Start = function()
  if not wd.a then return end
  wd.v = wd.v + 1
  wd.e = {}
  local lc = p.GetLocalCharacter()
  local px, py, pz = o.GetPosition(lc)
  local yaw = o.GetYaw(lc)
  h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage="WAVE "..wd.v.." START!",nPriority=1,nDuration=4})
  a.SetAttitude(wd.p, wd.g, 1)
  a.SetAttitude(wd.g, wd.p, 1)
  a.SetRelation(wd.p, wd.g, -100)
  a.SetRelation(wd.g, wd.p, -100)
  local nh = math.ceil(wd.v/2)
  local count = 0
  for w=1,nh do
    local sx, sz = px+35+(w*5), pz+35-(w*5)
    local ok, hl = pcall(Pg.Spawn, "UH1 Transport (GR) (Full)", sx, py+45, sz, yaw, false, true)
    if ok and hl then
      local okr, rds = pcall(Vehicle.GetRiders, hl)
      if okr and rds then
        for seat, rider in pairs(rds) do
          local idx = #wd.e + 1
          G["WE_"..idx] = rider
          table.insert(wd.e, rider)
          count = count + 1
          pcall(o.SetPosition, rider, sx+(seat*0.8), py, sz-(seat*0.8))
          pcall(a.SetAttitude, rider, lc, 1)
          pcall(a.SetAttitude, lc, rider, 1)
          pcall(a.Role, {AIGuid=rider,Role="Follow",Target=lc,MinDistance=4,MoveDistance=8,MaxDistance=150,Priority="medPri"})
        end
      end
      pcall(o.Remove, hl)
    end
  end
  h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage=count.." SOLDIERS INCOMING!",nPriority=1,nDuration=3})
  pcall(e.Create, e.TimerRelative, {1}, wd.Tick)
end

wd.Tick = function()
  if not wd.a then return end
  local lc = p.GetLocalCharacter()
  if not lc or not o.IsValid(lc) or not o.IsAlive(lc) or o.GetHealth(lc)<=0 then
    h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage="GAME OVER! WAVE:"..wd.v.." KILLS:"..wd.k,nPriority=1,nDuration=6})
    wd.Stop()
    return
  end
  local rem = {}
  for _, enemy in ipairs(wd.e) do
    if o.IsValid(enemy) and o.IsAlive(enemy) and o.GetHealth(enemy)>0 then
      table.insert(rem, enemy)
      pcall(a.SetAttitude, enemy, lc, 1)
      pcall(a.SetAttitude, lc, enemy, 1)
    else
      wd.k = wd.k + 1
      local reward = 5000 * wd.v
      pcall(p.AddCash, p.GetLocalPlayer(), reward)
      h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage="Killed! +$"..reward,nPriority=1,nDuration=2})
    end
  end
  wd.e = rem
  if #wd.e == 0 then
    h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage="WAVE COMPLETED!",nPriority=1,nDuration=4})
    pcall(e.Create, e.TimerRelative, {5}, wd.Start)
  else
    pcall(e.Create, e.TimerRelative, {1}, wd.Tick)
  end
end

wd.Stop = function()
  wd.a = false
  a.SetAttitude(wd.p, wd.g, 3)
  a.SetAttitude(wd.g, wd.p, 3)
  a.SetRelation(wd.p, wd.g, 100)
  a.SetRelation(wd.g, wd.p, 100)
  for _, enemy in ipairs(wd.e) do
    if o.IsValid(enemy) then pcall(o.Remove, enemy) end
  end
  wd.e = {}
  h.MessageBox:AddMessage({vPlayer=p.GetLocalPlayer(),sMessage="WAVE DEFENSE STOPPED.",nPriority=1,nDuration=4})
end

wd.a = true
wd.v = 0
wd.k = 0
wd.Start()
