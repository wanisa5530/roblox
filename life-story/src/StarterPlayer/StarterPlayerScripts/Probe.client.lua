-- ส่งสัญญาณว่า LocalScript ทำงาน + รายงาน error ฝั่งผู้เล่นทั้งหมดไปเซิร์ฟเวอร์ (ก่อนโหลดโมดูลอื่น)
local RS = game:GetService("ReplicatedStorage")
local f = RS:WaitForChild("RemoteFolder", 30)
local act = f and f:WaitForChild("Action", 30)
if act then
	act:FireServer("clientError", "probe alive; scripts=" .. #script.Parent:GetChildren())
	game:GetService("ScriptContext").Error:Connect(function(msg, trace) act:FireServer("clientError", msg .. " | " .. tostring(trace):sub(1, 120)) end)
	local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	task.delay(8, function() local n = {}; for _, g in ipairs(pg:GetChildren()) do n[#n + 1] = g.Name .. (g:IsA("ScreenGui") and (g.Enabled and "+" or "-") or "") end; act:FireServer("clientError", "guis: " .. table.concat(n, ",")) end)
end
