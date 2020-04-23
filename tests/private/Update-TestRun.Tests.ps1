$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Write-Log {}
function Invoke-XesterRestCall {}
Describe "Update-TestRun function for $moduleName" -Tags Build {
    It "Should Return false when -WhatIf is used." {
        Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1 -WhatIf | Should be $false
    }
    It "Should return 1 when the logfile is not specified." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1 | Should be 1
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should return 1." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1 | Should be 1
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should throw when Invoke-XesterRestCall Fails." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            Throw "Invoke-XesterRestCall failed"
        }
        {Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should not throw when Invoke-XesterRestCall succeeds." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        {Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1} | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
}