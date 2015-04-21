#### Description

Custom Metadata Type will be available in Summer 2015 and will enable salesforce developer to create custom packageable records !

This sample application demonstrates how to use custom metadata types to build a standard configuration screen similar to the Settings Manager built by SalesforceFoundation/Cumulus  <a href="https://github.com/SalesforceFoundation/Cumulus/blob/dev/src/pages/STG_SettingsManager.page" target="_blank">Settings Manager</a> . Custom metadata types are superior to list custom settings or custom objects for application configurations. The latter require writing post-install scripts or loading data manually after each deployment. Custom metadata types automate that process. 

The other nice advantage is that Custom Metadata Records are stored in memory and are exempted from number of SOQL limits even if SOQL functionality is more limited.

This sample application is also using the great <a href="https://github.com/financialforcedev/apex-mdapi" target="_blank">Apex metadata wrapper api</a> framework.

Below is a preview of the UI :

![MConfiguration App Demo Screenshot](https://github.com/jbpringuey/SFDCConfig/blob/master/images/Configuration.png)

Custom Metadata helps you make deployment to various orgs less painfull :

![Deploy to prod Screenshot](https://github.com/jbpringuey/SFDCConfig/blob/master/images/DeployToProd.png)

Custom Metadata helps you better distribute your packages with custom metadata :

![ISV intallation Screenshot](https://github.com/jbpringuey/SFDCConfig/blob/master/images/ISVInstallation.png)
