$script:ModuleName = 'Xester'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
function Get-Date {}
Describe "Get-XsTimeStamp function for $moduleName" -Tags Build {
    It "Should Return a String." {
        Mock -CommandName 'Get-Date' -MockWith {
            return "04222020-15:36:43"
        }
        Get-XsTimeStamp | Should not be $null
        Assert-MockCalled -CommandName 'Get-Date' -Times 1 -Exactly -Scope It
    }
    It "Should not throw when a String is returned." {
        Mock -CommandName 'Get-Date' -MockWith {
            return "04222020-15:36:43"
        }
        {Get-XsTimeStamp} | Should not Throw
        Assert-MockCalled -CommandName 'Get-Date' -Times 1 -Exactly -Scope It
    }
    It "Should throw when Get-Date fails." {
        Mock -CommandName 'Get-Date' -MockWith {
            Throw "Get-Date failed."
        }
        {Get-XsTimeStamp} | Should Throw
        Assert-MockCalled -CommandName 'Get-Date' -Times 1 -Exactly -Scope It
    }
}