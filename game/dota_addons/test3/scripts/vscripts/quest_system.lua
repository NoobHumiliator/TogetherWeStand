if QuestSystem ==nil then
        QuestSystem=class({})
    QuestSystem.InfoTable={}
end


--创建一个定时任务
function QuestSystem:CreateTimeLimitQuest(qusetName,qusetText,QuestCallback,time)
    if QuestSystem:CreateQuest(qusetName,qusetText,0,time,QuestCallback) then
        Timers:CreateTimer(1, function()
            for i=1,#QuestSystem.InfoTable do
                if QuestSystem.InfoTable[i][1] == qusetName then 
                    QuestSystem.InfoTable[i][3]=QuestSystem.InfoTable[i][3]+1
                    QuestSystem:RefreshQuest(qusetName,QuestSystem.InfoTable[i][3],QuestSystem.InfoTable[i][4])
                    if QuestSystem.InfoTable[i][3]<QuestSystem.InfoTable[i][4] then
                        return 1
                    else
                        return nil
                    end
                end 
            end 
            return nil
        end)   
    end
end

--创建一个任务
function QuestSystem:CreateQuest(qusetName,qusetText,questValueStart,questValueEnd,questCallback,remark)
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            print("Error:Aready have a same name quest")
            return false
        end 
    end 
    local questTable={qusetName,qusetText,questValueStart,questValueEnd,questCallback,remark}
    table.insert(QuestSystem.InfoTable, questTable)
    CustomGameEventManager:Send_ServerToAllClients( "createquest", {name=qusetName,text = qusetText, svalue = questValueStart,evalue=questValueEnd})
    QuestSystem:RefreshQuest(qusetName,questValueStart,questValueEnd,remark)
    -- QuestSystem:RefreshQuest(qusetName,questValueStart,questValueEnd)
    print("Quest Create Success")
    return true
end

function QuestSystem:CreateAchQuest(qusetName,qusetText,questValueStart,questValueEnd,questCallback,itemName)
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            print("Error:Aready have a same name quest")
            return false
        end 
    end 
    local questTable={qusetName,qusetText,questValueStart,questValueEnd,questCallback,itemName}
    table.insert(QuestSystem.InfoTable, questTable)
    CustomGameEventManager:Send_ServerToAllClients( "createachquest", {name=qusetName,text = qusetText, svalue = questValueStart,evalue=questValueEnd,itemname=itemName})
    QuestSystem:RefreshAchQuest(qusetName,questValueStart,questValueEnd)
    print("Quest Create Success")
    return true
end

function QuestSystem:CreatAffixesQuest(qusetName,list)
    CustomGameEventManager:Send_ServerToAllClients( "createaffixes", {name=qusetName,list = list})
    return true
end





--删除一个任务
function QuestSystem:DelQuest(qusetName)
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then
            if QuestSystem.InfoTable[i][5]~=nil then
               QuestSystem.InfoTable[i][5]()
            end
            CustomGameEventManager:Send_ServerToAllClients( "removequestpui", {name=QuestSystem.InfoTable[i][1]})
            table.remove(QuestSystem.InfoTable,i) 
            --i = i-1
            return
        end 
    end 
end






--刷新一个任务的数据
function QuestSystem:RefreshQuest(qusetName,questValueStart,questValueEnd)
    --[[
    if questValueStart>=questValueEnd then
        QuestSystem:DelQuest(qusetName)
        return
    end
    ]]
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            QuestSystem.InfoTable[i][3]=questValueStart
            QuestSystem.InfoTable[i][4]=questValueEnd
            if QuestSystem.InfoTable[i][6]~=nil then
                local remark=QuestSystem.InfoTable[i][6]
                CustomGameEventManager:Send_ServerToAllClients( "refreshquestdata", {name=QuestSystem.InfoTable[i][1],text = QuestSystem.InfoTable[i][2], svalue = QuestSystem.InfoTable[i][3],evalue=QuestSystem.InfoTable[i][4],remark=remark})
            else
                CustomGameEventManager:Send_ServerToAllClients( "refreshquestdata", {name=QuestSystem.InfoTable[i][1],text = QuestSystem.InfoTable[i][2], svalue = QuestSystem.InfoTable[i][3],evalue=QuestSystem.InfoTable[i][4]})
            end
            return
        end 
    end
    print("error: try to operation a nil Quest!!!") 
end



--刷新一个任务的数据
function QuestSystem:RefreshAchQuest(qusetName,questValueStart,questValueEnd)
    --[[
    if questValueStart>=questValueEnd then
        QuestSystem:DelQuest(qusetName)
        return
    end
    ]]
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            QuestSystem.InfoTable[i][3]=questValueStart
            QuestSystem.InfoTable[i][4]=questValueEnd
            CustomGameEventManager:Send_ServerToAllClients( "refreshachquestdata", {name=qusetName,text = QuestSystem.InfoTable[i][2],svalue = QuestSystem.InfoTable[i][3],evalue=QuestSystem.InfoTable[i][4]})
            return
        end 
    end
    print("error: try to operation a nil Quest!!!") 
end















--判断一个任务是否存在
function QuestSystem:CheckQuest(qusetName)

    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            return true
        end 
    end
    return false

end