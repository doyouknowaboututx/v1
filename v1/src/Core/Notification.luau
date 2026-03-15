local Notification = {}

function Notification.Notify(msg, duration, icon)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ChloeX Notification",
        Text = msg or "",
        Icon = icon or "rbxassetid://95750353626660",
        Duration = duration or 3,
    })
end

function chx(msg, duration, icon)
    Notification.Notify(msg, duration, icon)
end

return Notification
