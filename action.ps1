# HelloID-Task-SA-Target-ExchangeOnpremises-DistributionGroupCreate
###############################################################

# Exchange connection settings.  In this example from global HelloId custom variables

# Form mapping
$formObject = @{
    Name               = $form.CommonName
    DisplayName        = $form.DisplayName
    PrimarySmtpAddress = $form.PrimarySmtpAddress
    Alias              = $form.Alias
    OrganizationalUnit = $form.OU
}
[bool]$IsConnected = $false
try {
    Write-Information "Executing ExchangeOnpremises action: [DistributionGroupCreate] for: [$($formObject.DisplayName)]"

    $adminSecurePassword = ConvertTo-SecureString -String $ExchangeAdminPassword -AsPlainText -Force
    $adminCredential = [System.Management.Automation.PSCredential]::new($ExchangeAdminUsername, $adminSecurePassword)
    $sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnectionUri -Credential $adminCredential -SessionOption $sessionOption -Authentication Kerberos  -ErrorAction Stop
    $null = Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber -CommandName 'New-DistributionGroup'
    $IsConnected = $true

    $createdDistributionGroup = New-DistributionGroup @formObject -ErrorAction Stop

    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'ExchangeOnPremises'
        TargetIdentifier  = $createdDistributionGroup.ExchangeObjectId
        TargetDisplayName = $createdDistributionGroup.Name
        Message           = "ExchangeOnpremises  action: [DistributionGroupCreate] for: [$($formObject.DisplayName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "ExchangeOnpremises action: [DistributionGroupCreate] for: [$($formObject.DisplayName)] executed successfully"
} catch {
    $ex = $_
    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'ExchangeOnPremises'
        TargetIdentifier  = $formObject.Name
        TargetDisplayName = $formObject.Name
        Message           = "Could not execute ExchangeOnpremises  action: [DistributionGroupCreate] for: [$($formObject.DisplayName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Error "Could not execute ExchangeOnpremises  action: [DistributionGroupCreate] for: [$($formObject.DisplayName)], error: $($ex.Exception.Message)"
} finally {
    if ($IsConnected) {
        Remove-PsSession -Session $exchangeSession -Confirm:$false  -ErrorAction Stop
        }
}
###############################################################
