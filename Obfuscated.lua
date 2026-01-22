local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm xử lý sự kiện khi người chơi bấm nút
local function onButtonCallback(option)
    if option == "Yes" then
        print("???")
        
        getgenv().Key = "MARU-O9LA4-RJLQ-FT6O-CCH2T-GIQT4"
getgenv().id = "1249558116761342016"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xshiba/MaruBitkub/main/Mobile.lua"))()
        
    elseif option == "No" then
        print("OK.")
    end
end

-- Tạo BindableFunction để kết nối
local bindable = Instance.new("BindableFunction")
bindable.OnInvoke = onButtonCallback

task.spawn(function()
    local success = false
    repeat
        success = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Hello, " .. LocalPlayer.Name;
                Text = "Do you want to execute Maru?";
                Icon = "rbxassetid://119864182948748"; -- Đã thêm Icon của bạn vào đây
                Duration = 30;
                Callback = bindable;
                Button1 = "Yes";
                Button2 = "No";
            })
        end)
        if not success then
            task.wait(1)
        end
    until success
end)
