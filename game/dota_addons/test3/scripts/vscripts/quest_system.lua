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
function QuestSystem:CreateQuest(qusetName,qusetText,questValueStart,questValueEnd,QuestCallback)
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            print("Error:Aready have a same name quest")
            return false
        end 
    end 
    questtable={qusetName,qusetText,questValueStart,questValueEnd,QuestCallback}
    table.insert(QuestSystem.InfoTable, questtable)
    CustomGameEventManager:Send_ServerToAllClients( "createquest", {name=qusetName,text = qusetText, svalue = questValueStart,evalue=questValueEnd})
    QuestSystem:RefreshQuest(qusetName,questValueStart,questValueEnd)
    -- QuestSystem:RefreshQuest(qusetName,questValueStart,questValueEnd)
    print("Quest Create Success")
    return true
end
--删除一个任务
function QuestSystem:DelQuest(qusetName)
    for i=1, #QuestSystem.InfoTable do
        if QuestSystem.InfoTable[i][1] == qusetName then 
            QuestSystem.InfoTable[i][5]()
            CustomGameEventManager:Send_ServerToAllClients( "removequestpui", {name=QuestSystem.InfoTable[i][1]})
            table.remove(QuestSystem.InfoTable,i) 
            i = i-1
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
            CustomGameEventManager:Send_ServerToAllClients( "refreshquestdata", {name=QuestSystem.InfoTable[i][1],text = QuestSystem.InfoTable[i][2], svalue = QuestSystem.InfoTable[i][3],evalue=QuestSystem.InfoTable[i][4]})
            return
        end 
    end
    print("error: try to operation a nil Quest!!!") 
end