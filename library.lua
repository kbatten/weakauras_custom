function()
    WA = {}
    
    function WA:UnitKillable()
        return UnitCanAttack("player", "target") and not UnitIsDeadOrGhost("target")
    end
    
    function WA:SpellRange(...)
        local function IsSpellInRange(...)
            local args = {...}
            if ""..args[1] == "Frost Bomb" then
                args[1] = "Frostfire Bolt"
            end
            return _G["IsSpellInRange"](unpack(args))
        end
        
        for _, spellName in pairs({...}) do
            if (IsSpellInRange(spellName, "target") or 0) == 1 then
                return true
            end
        end
    end
    
    function WA:Range(range)
        if range == 25 and (IsItemInRange(31463, "target") or 0) == 1 then
            return true
        end
    end
    
    function WA:InUntrigger(value)
        if value then
            wa_inuntrigger = value
        end
        return wa_inuntrigger
    end
    
    function WA:SpellReady(spellName, timeTravel)
        local start, duration = GetSpellCooldown(spellName)
        if not start or start == 0 then
            return true
        end
        
        -- check for gcd
        if duration <= 1.5 then
            -- don't change state if GCD
            if WA:InUntrigger() then
                return true
            else
                return false
            end
        end
        
        if timeTravel and (duration - (GetTime() - start) <= timeTravel) then
            return true
        end
    end
    
    function WA:DebuffMissing(debuffName, timeTravel, stacks)
        local name, _, _, count, _, _, expirationTime = UnitDebuff("target", debuffName, "", PLAYER)
        if not name then
            return true
        end
        
        if timeTravel and (expirationTime - GetTime()) <= timeTravel then
            return true
        end
        
        if stacks and count < stacks then
            return true
        end
    end
    
    function WA:Debuff(...)
        return not WA:DebuffMissing(...)
    end
    
    function WA:BuffMissing(buffName, timeTravel)
        local name, _, _, _, _, _, expirationTime = UnitBuff("player", buffName, "", PLAYER)
        if not name then
            return true
        end
        
        if timeTravel and (expirationTime - GetTime()) <= timeTravel then
            return true
        end
    end
    
    function WA:Buff(...)
        return not WA:BuffMissing(...)
    end
    
    function WA:SpellCost(spellName, buffer)
        local function GetSpellInfo(...)
            local r = {...}
            if ""..r[1] == "Jab" then
                r[1] = "Expel Harm"
            end
            return _G["GetSpellInfo"](unpack(r))
        end
        
        buffer = buffer or 0
        local _, _, _, cost, _, powerType = GetSpellInfo(spellName)
        if cost and UnitPower("player", powerType) >= (cost + buffer) then
            return true
        end
    end
    
    function WA:SpellOvercap(spellName)
        local _, specName = GetSpecializationInfo(GetSpecialization())
        local generated = 0
        if spellName == "Jab" or spellName == "Expel Harm" then
            generated = 1
            if specName == "Windwalker" then
                generated = 2
            end
        elseif spellName == "Keg Smash" then
            generated = 2
        end
        if (UnitPower("player", 12) + generated) > UnitPowerMax("player", 12) then
            return true
        end
        return false
    end
    
    function WA:ComboAnticipationText()
        local combo = GetComboPoints("player", "target")
        local _, _, _, anticipation = UnitBuff("player", "Anticipation", "", PLAYER)
        local text = "0   0"
        if anticipation and combo > 0 then
            text = anticipation.."   "..combo
        elseif anticipation then
            -- text = "" .. anticipation
            text = anticipation.."   0"
        elseif combo > 0 then
            -- text = "" .. combo
            text = "0   "..combo
        end
        return text
    end 
    
    function WA:BuffExpirationText(buffName, timeTravel)
        local _, _, _, _, _, _, expirationTime = UnitBuff("player", buffName, "", PLAYER)
        local curTime = GetTime()
        local str = ""
        
        if expirationTime and (expirationTime - curTime) < timeTravel then
            local val = ceil((expirationTime - curTime) * 10) / 10
            if ceil(val) == val then
                str = ""..val..".0"
            else
                str = ""..val
            end
        end
        return str
    end
    
    
    function WA:ColorOutOfRange()
        return 1, 0.4, 0.4
    end
    
    function WA:ColorNotOptimal()
        return 1, 1, 0.4
    end
    
    function WA:ColorNotEnoughPower()
        return 0.4, 0.4, 1
    end
    
    function WA:AlphaNotReady()
        return 0.6
    end
end
