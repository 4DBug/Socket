local Socket = loadstring(game:HttpGet("https://socket.bug.tools/"))()

local Channel = Socket.Connect(0xC0FFEE)

Channel.OnMessage:Connect(function(Player, MessageId, Content)
    local Message = game.CoreGui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView:WaitForChild(MessageId).TextMessage.BodyText

    Message.Text = string.format("%s: %s", Player.DisplayName, Content)

    Message:GetPropertyChangedSignal("Text"):Once(function()
        Message.Text = string.format("%s: %s", Player.DisplayName, Content)
    end)
end)

local TextChatService = game:GetService("TextChatService")

local Received = {}
TextChatService.OnIncomingMessage = function(Message)
    if Message.TextSource.UserId == game.Players.LocalPlayer.UserId then
        if not string.find(Message.Text, "#") then
            Received[Message.MessageId] = Message.Text
        else
            Channel:Send(Message.MessageId, Received[Message.MessageId])
        end
    end
end
