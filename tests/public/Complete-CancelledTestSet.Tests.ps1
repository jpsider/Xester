$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Get-TestRunSet {}
function Write-Log {}
function Update-TestRun {}
Describe "Complete-CancelledTestSet function for $moduleName" -Tags Build {
    It "Should Return false when -WhatIf is used." {
        Complete-CancelledTestSet -RestServer localhost -WhatIf | Should be $false
    }
    It "Should null when tests are updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TestRunSet' -MockWith {
            $RawReturn = @{
                testrun = @{
                    ID            = '1'
                    STATUS_ID     = '6'
                    RESULT_ID       = '3'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
        Mock -CommandName 'Update-TestRun' -MockWith {
            return 1
        }
        Complete-CancelledTestSet -RestServer localhost | Should be $null
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
    }
    It "Should not Throw when tests are updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TestRunSet' -MockWith {
            $RawReturn = @{
                testrun = @{
                    ID            = '1'
                    STATUS_ID     = '6'
                    RESULT_ID       = '3'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
        Mock -CommandName 'Update-TestRun' -MockWith {
            return 1
        }
        {Complete-CancelledTestSet -RestServer localhost} | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
    }
    It "Should Throw when tests are not updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TestRunSet' -MockWith {
            $RawReturn = @{
                testrun = @{
                    ID            = '1'
                    STATUS_ID     = '6'
                    RESULT_ID       = '3'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
        Mock -CommandName 'Update-TestRun' -MockWith {
            Throw "Update failed"
        }
        {Complete-CancelledTestSet -RestServer localhost} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
    }
    It "Should Throw when tests are not retrieved." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TestRunSet' -MockWith {
            throw "Failed Get-TestRunSet"
        }
        Mock -CommandName 'Update-TestRun' -MockWith {}
        {Complete-CancelledTestSet -RestServer localhost} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 0 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
    }
}