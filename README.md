# Copy Table Data Between Two Tenants of SAP BTP ABAP Environment (Tenant Copy) 
This Git repository provides an utility to copy table data from one [SAP BTP ABAP Environment](https://community.sap.com/topics/btp-abap-environment)  (aka "Steampunk") tenant to another tenant. The code is compliant to [ABAP Cloud](https://community.sap.com/topics/abap). 

The utility consists of two communication scenarios, one for **outbound** communication to push the data and the other one for **inbound** communication. To trigger the tenant copy, you need to start an application job based on a pre-defined Application Job Catalog Entry. The application job execution creates log entries about the covered custom tables and number of copied rows.

The utility supports only *custom-defined* database tables, but not SAP-delivered database tables. All types of database tables are supported. Please consider the implications if you are push data of client-independent tables, configuration tables or system tables. The copy logic supports paging to handle also huge amount of data per table.

The utility represents example code. Feel free to extend it depending on your needs. Limitations of the current implementation are:
* The pushed data per database table **replaces** the existing data in the target tenant. There are no other operations supported like **append** or **modify** (without deletion).
* There is no value help to select the Communication Arrangement ID of the target tenant. You need to enter it manually as application job parameter.

Please grant the authorizations for the utility carefully. There is no further authorization check on table level. This utility is intended to be used by adminstators or key users only.

## Prerequisites
Make sure to fulfill the following requirements:
* You have access to an SAP BTP ABAP Environment instance (see [here](https://discovery-center.cloud.sap/serviceCatalog/abap-environment?region=all) or [here](https://help.sap.com/docs/sap-btp-abap-environment) for additional information).
* You have downloaded and installed ABAP Development Tools (ADT). Make sure to use the most recent version as indicated on the [installation page](https://tools.hana.ondemand.com/#abap). 
* You have created an ABAP Cloud Project in ADT that allows you to access your SAP BTP ABAP Environment instance (see [here](https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/creating-abap-cloud-project) for additional information). Your log-on language is English.
* You have installed the [abapGit](https://github.com/abapGit/eclipse.abapgit.org) plug-in for ADT from the update site `http://eclipse.abapgit.org/updatesite/`.

## Download
Use the abapGit plug-in to install the **Copy Table Data Between Two Tenants** by executing the following steps:
1. Open the Administrator's Fiori Launchpad and start the app **Maintain Software Components**. Create a new software component `ZCCSD` of type *Development*. Press the button *Clone* which creates the software component and the stucture package with the same name `ZCCSD` in the respective ABAP system (see [here](https://help.sap.com/docs/sap-btp-abap-environment/abap-environment/how-to-create-software-components) for additional information).
2. In your ABAP cloud project, create the ABAP package `ZCCSD_MAIN` (using the superpackage `ZCCSD`) as the target package for the utility to be downloaded (leave the suggested values unchanged when following the steps in the package creation wizard).
3. To add the <em>abapGit Repositories</em> view to the <em>ABAP</em> perspective, click `Window` > `Show View` > `Other...` from the menu bar and choose `abapGit Repositories`.
4. In the <em>abapGit Repositories</em> view, click the `+` icon to clone an abapGit repository.
5. Enter the following URL of this repository: `https://github.com/frankjentsch/copy-custom-data.git` and choose <em>Next</em>.
6. Select the branch <em>refs/heads/main</em> and enter the newly created package `ZCCSD_MAIN` as the target package and choose <em>Next</em>.
7. Create a new transport request that you only use for this utility installation (recommendation) and choose <em>Finish</em> to link the Git repository to your ABAP cloud project. The repository appears in the abapGit Repositories View with status <em>Linked</em>.
8. Right-click on the new ABAP repository and choose `Pull ...` to start the cloning of the repository content. Note that this procedure may take a few seconds. 

As a result of the installation procedure above, the ABAP system creates an inactive version of all artifacts for the utility. Further manual steps are required to finally use the utility. Please refer to the next section.

## Configuration

To activate all development objects from the `ZCCSD_MAIN` package: 
1. Click the mass-activation icon (<em>Activate inactive ABAP development objects</em>) in the toolbar.  
2. In the dialog that appears, select all development objects in the transport request (that you created for the utility installation) and choose `Activate`.

To transport the finally completed utility:
1. Release the task and transport via ADT view `Transport Organizer`. As a result of this release, the developed objects of that software component are written into a hidden Git repository.
2. Import the utility in a subsequent system: Open the Administrator's Fiori Launchpad of the subsequent system and start the app **Maintain Software Components**. Press the button *Clone* which imports all the released objects into the subsequent system.

You need to import the utility via the app **Maintain Software Components** (not via abapGit) into all systems which need to support the tenant copy. For example, if you want the copy the data from a tenant in the production system into a tenant of a pre-production system for testing purposes, you need to import the untility into the production system (source of the tenant copy) and into the pre-production system (target of the tenant copy). 

## How it works

The basic approach is as follows:
* The tenant copy is based on a configured **template for tenant copy**. The template defines the scope for a tenant copy execution. The scope can be defined based on software components, tables, and table fields (filter). 
* A SAP Fiori app in the *source* tenant (= *push* principle) is used to define the templates. The actual template is specified as one of the application job parameters.
* The supported target tenants are determined based on the configured outbound Communication Arrangements of a certain Communication Scenario. You need to enter the Communication Arragement ID as one of the application job parameters.
* The data transfer to the target tenant is implemented by a Remote Function Call (RFC) using the respective Communication Scenario.
* The RFC execution in the target tenant replaces the data of all database tables of the configured copy template in the target tenant.
* The SAP Fiori app Application Jobs is also used to show the log of all performed data transfers to the target tenant.

### Example

This Git repository contains also two database tables to test the data transfer:
* `ZCCSD_DEMO_TAB_1` - represents a typical table of a RAP Managed BO with UUID as primary key and different timestamp fields
* `ZCCSD_DEMO_TAB_2` - represents a table with a CHAR field as a primary key

Class `ZCL_CCSD_SETUP_DEMO_DATA` is a console app which can be used to fill test data in the source tenant into these two tables.

### Configure Templates for Tenant Copy

A tenplate defines a collection of custom database tables which will be pushed as one action later via an application job. In our example, we define one template for the two example tables. The same database table can be used in different templates. The template name and description need to be maintained in configuration table `ZCCSD_TEMPLATE`. The optional table filter by software componentes and table names need to be maintained in configuration table `ZCCSD_TEMPLATE_T`. The optional data filter per table field need to be maintained in configuration table `ZCCSD_TEMPLATE_F`. You can use class `ZCL_CCSD_SETUP_DEMO_CONFIG` to create these configuration entries for the demo tables. 

Data preview of `ZCCSD_TEMPLATE`:

![](png/01%20-%20ZPUSH_TAB_GRP%20Data%20Preview.png)

Data preview of `ZCCSD_TEMPLATE_T`:

![](png/02%20-%20ZPUSH_TAB_GRP_I%20Data%20Preview.png)

### SAP Fiori App to Configure the Templates

A Business Configuration object based on OData V4 Service Binding `ZCCSD_UI_TEMPLATE_O4` is provided to define the templates for tenant copy.

![](png/03%20-%20Fiori%20App.png)

## How to obtain support
This project is provided "as-is": there is no guarantee that raised issues will be answered or addressed in future releases.

