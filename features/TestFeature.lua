--// DOORS FEATURE HUB
--// Test Feature

return {
    Name = "Test Feature",
    Description = "Tests that the feature system is working.",

    Start = function(self, Hub)
        print("[DOORS HUB] Test Feature started!")
    end,

    Stop = function(self, Hub)
        print("[DOORS HUB] Test Feature stopped!")
    end
}
