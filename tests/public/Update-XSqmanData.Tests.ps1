$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Get-XsTimeStamp {}
function Write-Log {}
function Invoke-XesterRestCall {}
Describe "Update-XSqmanData function for $moduleName" -Tags Build {
    It "Should Return false when -WhatIf is used." {
        Update-XSqmanData -RestServer localhost -Status 4 -QmanId 1 -WhatIf | Should be $false
    }
    It "Should return 1 when the logfile is not specified." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        Mock -CommandName 'Get-XsTimeStamp' -MockWith {
            return "04222020-15:36:43"
        }
        Update-XSqmanData -RestServer localhost -Status 4 -QmanId 1 | Should be 1
        Assert-MockCalled -CommandName 'Get-XsTimeStamp' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should return 1." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        Mock -CommandName 'Get-XsTimeStamp' -MockWith {
            return "04222020-15:36:43"
        }
        Update-XSqmanData -RestServer localhost -Status 4 -QmanId 1 -QmanLogFile "c:\test\test.log" | Should be 1
        Assert-MockCalled -CommandName 'Get-XsTimeStamp' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should throw when Invoke-XesterRestCall Fails." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            Throw "Invoke-XesterRestCall failed"
        }
        Mock -CommandName 'Get-XsTimeStamp' -MockWith {
            return "04222020-15:36:43"
        }
        {Update-XSqmanData -RestServer localhost -Status 4 -QmanId 1 -QmanLogFile "c:\test\test.log"} | Should Throw
        Assert-MockCalled -CommandName 'Get-XsTimeStamp' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should not throw when Invoke-XesterRestCall succeeds." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return 1
        }
        Mock -CommandName 'Get-XsTimeStamp' -MockWith {
            return "04222020-15:36:43"
        }
        {Update-XSqmanData -RestServer localhost -Status 4 -QmanId 1 -QmanLogFile "c:\test\test.log"} | Should not Throw
        Assert-MockCalled -CommandName 'Get-XsTimeStamp' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
}