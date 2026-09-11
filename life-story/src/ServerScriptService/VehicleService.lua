-- รถขับได้จริง: ซื้อรถ เรียกรถ นั่งขับ (W/S เร่ง-ถอย A/D เลี้ยว) ฟิสิกส์แบบง่ายด้วย LinearVelocity/AngularVelocity
local Config = require(game.ReplicatedStorage.Config)
local Core = require(script.Parent.Core)
local Map = require(script.Parent.MapService)
local Home = require(script.Parent.HomeService)
local V = { cars = {} }
local function part(props, parent)
	local p = Instance.new("Part"); p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent; return p
end
local function weld(a, b) local w = Instance.new("WeldConstraint"); w.Part0 = a; w.Part1 = b; w.Parent = a end
function V.cfg(key) for _, c in ipairs(Config.Cars) do if c.key == key then return c end end end
-- สร้างรถขับได้ (ตัวถังโค้ง กระจกเอียง ล้อ ไฟ) ให้ผู้เล่น
function V.spawnCar(p, key, pos)
	V.despawn(p)
	local cc = V.cfg(key); if not cc then return end
	local color = Color3.fromRGB(unpack(cc.color))
	local m = Instance.new("Model"); m.Name = "Car_" .. p.UserId; m:SetAttribute("Owner", p.UserId)
	local cf = CFrame.new(pos + Vector3.new(0, 2.2, 0))
	local chassis = part({ Size = Vector3.new(6, 1.4, 13), CFrame = cf, Color = color, Material = Enum.Material.Metal, Reflectance = 0.15, Name = "Chassis", CustomPhysicalProperties = PhysicalProperties.new(2, 0.6, 0.3) }, m)
	m.PrimaryPart = chassis
	local function sub(props) local q = part(props, m); q.Massless = true; q.CanCollide = false; weld(chassis, q); return q end
	sub({ Size = Vector3.new(5.6, 1.5, 6.5), CFrame = cf * CFrame.new(0, 1.45, 0.3), Color = color, Material = Enum.Material.Metal, Reflectance = 0.15 })
	local hood = Instance.new("WedgePart"); hood.Size = Vector3.new(5.8, 1.0, 3.2); hood.CFrame = cf * CFrame.new(0, 1.2, -4.9) * CFrame.Angles(0, math.pi, 0); hood.Color = color; hood.Material = Enum.Material.Metal; hood.Massless = true; hood.CanCollide = false; hood.Parent = m; weld(chassis, hood)
	local w1 = Instance.new("WedgePart"); w1.Size = Vector3.new(5.6, 1.5, 2.6); w1.CFrame = cf * CFrame.new(0, 1.45, -4.2) * CFrame.Angles(0, math.pi, 0); w1.Color = Color3.fromRGB(40, 60, 80); w1.Material = Enum.Material.Glass; w1.Transparency = 0.35; w1.Massless = true; w1.CanCollide = false; w1.Parent = m; weld(chassis, w1)
	local w2 = Instance.new("WedgePart"); w2.Size = Vector3.new(5.6, 1.5, 2.2); w2.CFrame = cf * CFrame.new(0, 1.45, 4.7); w2.Color = Color3.fromRGB(40, 60, 80); w2.Material = Enum.Material.Glass; w2.Transparency = 0.35; w2.Massless = true; w2.CanCollide = false; w2.Parent = m; weld(chassis, w2)
	for _, sx in ipairs({ -1, 1 }) do
		sub({ Size = Vector3.new(0.2, 1.1, 5.8), CFrame = cf * CFrame.new(sx * 2.85, 1.45, 0.3), Color = Color3.fromRGB(40, 60, 80), Material = Enum.Material.Glass, Transparency = 0.4 })
		sub({ Size = Vector3.new(0.3, 0.3, 0.8), CFrame = cf * CFrame.new(sx * 3.2, 1.1, -2.2), Color = color, Material = Enum.Material.Metal })
		for _, z in ipairs({ -4, 4 }) do
			local wheel = sub({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.9, 2.2, 2.2), CFrame = cf * CFrame.new(sx * 2.8, -0.9, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(25, 25, 25), Material = Enum.Material.Rubber })
			wheel.CanCollide = true; wheel.Name = "Wheel"
			sub({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.95, 1.3, 1.3), CFrame = cf * CFrame.new(sx * 2.85, -0.9, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Metal, Reflectance = 0.4 })
		end
		local hl = sub({ Size = Vector3.new(1.2, 0.6, 0.3), CFrame = cf * CFrame.new(sx * 2, 0.3, -6.6), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon })
		local l = Instance.new("SpotLight"); l.Range = 40; l.Angle = 70; l.Brightness = 2; l.Face = Enum.NormalId.Front; l.Parent = hl
		sub({ Size = Vector3.new(1.2, 0.5, 0.3), CFrame = cf * CFrame.new(sx * 2, 0.3, 6.6), Color = Color3.fromRGB(230, 40, 40), Material = Enum.Material.Neon })
	end
	sub({ Size = Vector3.new(6.2, 0.6, 0.6), CFrame = cf * CFrame.new(0, -0.5, -6.6), Color = Color3.fromRGB(40, 40, 45) })
	sub({ Size = Vector3.new(6.2, 0.6, 0.6), CFrame = cf * CFrame.new(0, -0.5, 6.6), Color = Color3.fromRGB(40, 40, 45) })
	sub({ Size = Vector3.new(1.6, 0.5, 0.1), CFrame = cf * CFrame.new(0, -0.1, 6.75), Color = Color3.fromRGB(250, 250, 250) })
	-- เบาะคนขับ
	local seat = Instance.new("VehicleSeat"); seat.Size = Vector3.new(2, 0.5, 2); seat.CFrame = cf * CFrame.new(-1.2, 1.0, -0.5); seat.Transparency = 1; seat.CanCollide = false; seat.Massless = true; seat.MaxSpeed = cc.speed; seat.Torque = 0; seat.TurnSpeed = 0; seat.HeadsUpDisplay = false; seat.Name = "DriverSeat"; seat.Parent = m; weld(chassis, seat)
	local seat2 = Instance.new("Seat"); seat2.Size = Vector3.new(2, 0.5, 2); seat2.CFrame = cf * CFrame.new(1.2, 1.0, -0.5); seat2.Transparency = 1; seat2.CanCollide = false; seat2.Massless = true; seat2.Parent = m; weld(chassis, seat2)
	-- ฟิสิกส์
	local att = Instance.new("Attachment"); att.Parent = chassis
	local lv = Instance.new("LinearVelocity"); lv.Attachment0 = att; lv.RelativeTo = Enum.ActuatorRelativeTo.Attachment0; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = Vector3.zero; lv.ForceLimitsEnabled = true; lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis; lv.MaxAxesForce = Vector3.new(0, 0, 0); lv.Parent = chassis
	local av = Instance.new("AngularVelocity"); av.Attachment0 = att; av.RelativeTo = Enum.ActuatorRelativeTo.World; av.AngularVelocity = Vector3.zero; av.MaxTorque = 0; av.Parent = chassis
	local gyro = Instance.new("AlignOrientation"); gyro.Mode = Enum.OrientationAlignmentMode.OneAttachment; gyro.Attachment0 = att; gyro.MaxTorque = 0; gyro.Responsiveness = 20; gyro.Parent = chassis
	for _, x in ipairs(m:GetDescendants()) do if x:IsA("BasePart") then x.Anchored = false end end
	m.Parent = workspace
	-- ป้ายเจ้าของ + prompt เรียกใช้ (เจ้าของนั่งเองด้วยการเดินไปนั่ง)
	local pp = Instance.new("ProximityPrompt"); pp.ActionText = "Drive"; pp.ObjectText = Core.T(p, cc.key); pp.HoldDuration = 0; pp.MaxActivationDistance = 8; pp.RequiresLineOfSight = false; pp.Parent = chassis
	pp:SetAttribute("Action", "drive")
	pp.Triggered:Connect(function(who) if who == p and who.Character then local hum = who.Character:FindFirstChildOfClass("Humanoid"); if hum and not seat.Occupant then seat:Sit(hum) end end end)
	-- ลูปขับ: throttle/steer จาก VehicleSeat
	local mass = 0; for _, x in ipairs(m:GetDescendants()) do if x:IsA("BasePart") then mass += x:GetMass() end end
	local speed = 0
	local conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not m.Parent then return end
		local occ = seat.Occupant
		if occ then
			local target = seat.ThrottleFloat * cc.speed
			speed += (target - speed) * math.min(dt * (target ~= 0 and 1.2 or 2.5), 1)
			if math.abs(speed) < 0.2 then speed = 0 end
			lv.MaxAxesForce = Vector3.new(mass * 400, 0, mass * 400); lv.VectorVelocity = Vector3.new(0, 0, -speed)
			local turn = -seat.SteerFloat * cc.turn * math.clamp(math.abs(speed) / cc.speed, 0.15, 1) * (speed < 0 and -1 or 1)
			av.MaxTorque = mass * 4000; av.AngularVelocity = Vector3.new(0, turn, 0)
			gyro.MaxTorque = mass * 2000; gyro.CFrame = CFrame.fromOrientation(0, select(2, chassis.CFrame:ToOrientation()), 0)
			seat:SetNetworkOwner(nil)
		else
			speed = 0; lv.MaxAxesForce = Vector3.zero; av.MaxTorque = 0; gyro.MaxTorque = 0
		end
	end)
	V.cars[p] = { model = m, conn = conn, seat = seat, key = key }
	return m
end
function V.despawn(p)
	local c = V.cars[p]; if not c then return end
	if c.conn then c.conn:Disconnect() end
	if c.model then c.model:Destroy() end
	V.cars[p] = nil
end
-- ซื้อรถ
function V.buy(p, key)
	local ch = Core.char(p); if not ch then return false end
	local cc = V.cfg(key); if not cc then return false end
	if cc.pass and not Core.ownsPass(p, cc.pass) then game.ReplicatedStorage.RemoteFolder.PromptPass:FireClient(p, "pass", cc.pass); return false end
	if ch.car == key then return false end
	if cc.price > 0 and not Core.spend(p, cc.price) then return false end
	ch.car = key; Core.notify(p, "bought", "green", Core.T(p, key)); Core.push(p)
	V.callCar(p)
	return true
end
-- เรียกรถมาที่ตัว (วางบนถนนใกล้ๆ / หน้าบ้าน)
function V.callCar(p)
	local ch = Core.char(p); if not ch or not ch.car then return false end
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	local pos = hrp and (hrp.Position + hrp.CFrame.LookVector * 10) or (Home.homePos(p) + Vector3.new(14, 0, 10))
	local m = V.spawnCar(p, ch.car, Vector3.new(pos.X, 0.2, pos.Z))
	if m and hrp then m:PivotTo(CFrame.new(m:GetPivot().Position, m:GetPivot().Position + hrp.CFrame.LookVector)) end
	return m ~= nil
end
function V.onLeave(p) V.despawn(p) end
return V
