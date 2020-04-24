$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Get-TestRunSet {}
function Write-Log {}
function Update-TestRun {}
function Get-TmanData {}
Describe "Invoke-AssignQueuedTestSet function for $moduleName" -Tags Build {
    It "Should Return false when -WhatIf is used." {
        Invoke-AssignQueuedTestSet -RestServer localhost -WhatIf | Should be $false
    }
    It "Should null when tests are updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            $RawReturn = @{
                testrun_manager = @{
                    ID            = '1'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
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
        Invoke-AssignQueuedTestSet -RestServer localhost | Should be $null
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 1 -Exactly -Scope It
    }
    It "Should not Throw when tests are updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            $RawReturn = @{
                testrun_manager = @{
                    ID            = '1'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
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
        {Invoke-AssignQueuedTestSet -RestServer localhost} | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 1 -Exactly -Scope It
    }
    It "Should Throw when tests are not updated." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            $RawReturn = @{
                testrun_manager = @{
                    ID            = '1'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
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
        {Invoke-AssignQueuedTestSet -RestServer localhost} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 1 -Exactly -Scope It
    }
    It "Should Throw when tests are not retrieved." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            $RawReturn = @{
                testrun_manager = @{
                    ID            = '1'
                }               
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnJson | convertfrom-json
        }
        Mock -CommandName 'Get-TestRunSet' -MockWith {
            throw "Failed Get-TestRunSet"
        }
        Mock -CommandName 'Update-TestRun' -MockWith {}
        {Invoke-AssignQueuedTestSet -RestServer localhost} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 0 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 0 -Exactly -Scope It
    }
    It "Should Throw when Get-TmanData fails." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            Throw "Get-TmanData failed"
        }
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
        {Invoke-AssignQueuedTestSet -RestServer localhost} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 0 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 1 -Exactly -Scope It
    }
    It "Should not Throw when no TestRun Managers are available." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Get-TmanData' -MockWith {
            return $null
        }
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
        {Invoke-AssignQueuedTestSet -RestServer localhost} | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 2 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Update-TestRun' -Times 0 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TestRunSet' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Get-TmanData' -Times 1 -Exactly -Scope It
    }
}