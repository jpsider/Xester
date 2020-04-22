$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Write-Log {}
function Invoke-XesterRestCall {}
Describe "Get-XSqmanData function for $moduleName" -Tags Build {
    It "Should Return false when -WhatIf is used." {
        Get-XSqmanData -RestServer localhost -QmanId 1 -WhatIf | Should be $false
    }
    It "Should Return data when the call succeeds." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return "Qman data, lots of it"
        }
        Get-XSqmanData -RestServer localhost -QmanId 1 | Should not be $null
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should not throw when the call succeeds." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            return "Qman data, lots of it"
        }
        {Get-XSqmanData -RestServer localhost -QmanId 1 } | Should not Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
    It "Should throw when the Rest call fails." {
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-XesterRestCall' -MockWith {
            Throw "Invoke-XesterRestCall failed"
        }
        {Get-XSqmanData -RestServer localhost -QmanId 1} | Should Throw
        Assert-MockCalled -CommandName 'Write-Log' -Times 1 -Exactly -Scope It
        Assert-MockCalled -CommandName 'Invoke-XesterRestCall' -Times 1 -Exactly -Scope It
    }
}