$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Invoke-RestMethod { }
function Write-Log { }
Describe "Invoke-XesterRestCall function for $moduleName" -Tags Build {
    It "Should not be null when no Body is passed in." {
        Mock -CommandName 'Write-Log' -MockWith { }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            return "Data"
        }
        Invoke-XesterRestCall -RestServer localhost -URI "/queue_manager/1?transform=true" -Method Get | Should not be $null
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope It
    }
    It "Should not be null when a Body is passed in." {
        Mock -CommandName 'Write-Log' -MockWith { }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            return "Data"
        }
        Invoke-XesterRestCall -RestServer localhost -URI "/queue_manager/1?transform=true" -Method Get -Body "Some_Json" | Should not be $null
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope It
    }
    It "Should should throw when Invoke-RestMethod fails." {
        Mock -CommandName 'Write-Log' -MockWith { }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            Throw "Invoke-RestMethod Failed."
        }
        {Invoke-XesterRestCall -RestServer localhost -URI "/queue_manager/1?transform=true" -Method Get -Body "Some_Json"} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope It
    }
    It "Should not throw when Invoke-RestMethod succeeds." {
        Mock -CommandName 'Write-Log' -MockWith { }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            return "Data"
        }
        {Invoke-XesterRestCall -RestServer localhost -URI "/queue_manager/1?transform=true" -Method Get -Body "Some_Json"} | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope It
    }
}