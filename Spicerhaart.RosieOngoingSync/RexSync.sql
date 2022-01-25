use [InternetDBDev]

go

ALTER TABLE tbl_fwdaddr
ALTER COLUMN [vaddr_1] VARCHAR(250)

ALTER TABLE tbl_fwdaddr
ALTER COLUMN [vaddr_2] VARCHAR(250)

ALTER TABLE tbl_fwdaddr
ALTER COLUMN [fvaddr_1] VARCHAR(250)

ALTER TABLE tbl_fwdaddr
ALTER COLUMN [fvaddr_2] VARCHAR(250)

alter table tbl_customer
alter column addr_1 VARCHAR(250)

alter table tbl_customer
alter column addr_2 VARCHAR(250)

go

CREATE TABLE DMA_EstateAgent_Rosie_Mapping
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    OfficeID VARCHAR(4),
    EstateAgent VARCHAR(200),
    rid_local_agency INT
)

GO

alter table tbl_apps 
	add rid_matchprofile varchar(50) null,
	etag_matchprofile varchar(50) null
go

alter table tbl_staff
	add rid_accountuser int null,
	RosieDropboxEmail varchar(128) null,
	RosieLeadEmail varchar(128) null

go


alter table tbl_legal
	add rid_contact int null,
	etag_contact varchar(50) null
go

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'DMA_EstateAgent_Rosie_Mapping_ID'
	   AND Object_ID = Object_ID(N'dbo.DMA_Recipients')
)
BEGIN
    ALTER TABLE DMA_Recipients ADD DMA_EstateAgent_Rosie_Mapping_ID INT
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'rid_marketlead'
	   AND Object_ID = Object_ID(N'dbo.DMA_Recipients')
)
BEGIN
    ALTER TABLE DMA_Recipients ADD rid_marketlead INT
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'etag_marketlead'
	   AND Object_ID = Object_ID(N'dbo.DMA_Recipients')
)
BEGIN
    ALTER TABLE DMA_Recipients ADD etag_marketlead NVARCHAR(72)
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'rid_contract'
	   AND Object_ID = Object_ID(N'dbo.tbl_offer')
)
BEGIN
    ALTER TABLE tbl_offer ADD rid_contract INT
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'num_offers'
	   AND Object_ID = Object_ID(N'dbo.tbl_offer')
)
BEGIN
    ALTER TABLE tbl_offer ADD num_offers INT
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'etag_contract'
	   AND Object_ID = Object_ID(N'dbo.tbl_offer')
)
BEGIN
    ALTER TABLE tbl_offer ADD etag_contract NVARCHAR(72)
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.columns 
    WHERE Name = N'rid_substantiation'
	   AND Object_ID = Object_ID(N'dbo.tbl_offer')
)
BEGIN
    ALTER TABLE tbl_offer ADD rid_substantiation INT
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.indexes 
    WHERE name = 'IDX_tbl_offer_rid_contract' 
	   AND object_id = OBJECT_ID('dbo.tbl_offer')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_tbl_offer_rid_contract ON tbl_offer
    (
	    rid_contract
    )
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.indexes 
    WHERE name = 'IDX_DMA_Recipients_rid_marketlead' 
	   AND object_id = OBJECT_ID('dbo.DMA_Recipients')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IDX_DMA_Recipients_rid_marketlead] ON DMA_Recipients
    (
	    [rid_marketlead]
    )
END

GO

IF NOT EXISTS
(
    SELECT NULL
    FROM sys.indexes 
    WHERE name = 'IDX_DMA_Recipients_DMA_EstateAgent_Rosie_Mapping_ID' 
	   AND object_id = OBJECT_ID('dbo.DMA_Recipients')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IDX_DMA_Recipients_DMA_EstateAgent_Rosie_Mapping_ID] ON DMA_Recipients
    (
	    [DMA_EstateAgent_Rosie_Mapping_ID]
    )
END

GO

CREATE TABLE RosieCustomerMigration (
	ID int identity(1,1),
	CustomerID int not null,
	OfficeID varchar(4) not null,
	rid_contact int null,
	etag_contact varchar(50) null

)

go


USE [InternetDBDev]
GO
/****** Object:  StoredProcedure [dbo].[ROSIE_uspGetContactApplicant]    Script Date: 05/12/2018 17:23:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ROSIE_uspGetContactApplicant]
	@contact_id int
AS 
BEGIN

select
isnull(gstat.code_descr,'') as status,
isnull(gmm.code_descr,'') as 'expected_timescale',
case when isnull(a.HelpToBuy,0) = 0 then 'No' else 'Yes' end as 'interested_in_htb',
case when a.legal_case = 0 then 'No' else 'Yes' end as 'have_services_been_sold',
isnull(lr.code_descr,'') as 'no_reason',
isnull(instructed.rid_accountuser,19443) as 'instructed_by_user',
convert(varchar,a.instdate,23)  as 'date_instructed',
'[' + case when cast(isnull(a.product, '') as varchar) = 1 then '"Selling"'
			when cast(isnull(a.product, '') as varchar) = 2 then '"Selling", "Buying"' 
			else cast('' as varchar) end + ']' as 'product_sold',
isnull(legal_reas,'') as 'legal_status',
isnull(legal_val,0) as'legal_income',
isnull(leg.company,'') as 'conveyancer',
leg.rid_contact as 'conveyancer_rid',
leg.id as 'conveyancer_id',
case when a.fsappt_yn=0 then 'No' else 'Yes' end as 'appointment_made',
isnull(areason.code_descr,'') as 'appointment_reason',
isnull(referred.rid_accountuser,19443) as 'referred_by_user',
isnull(purch.code_descr,'') as 'purchasing_position',
case when len(isnull(A.Lender,''))=0 then 'No' else 'Yes' end as 'spoken_with_lender',
isnull(a.Lender,'') as 'lender_notes',
isnull(a.DepositAmount,0) as 'deposit_available',
isnull(mort.code_descr,'') as 'mortgage_type',
isnull(a.Ratesquoted,0) as 'rates_quoted',
case when isnull(a.ap_occur,0)=0 then 'No' else 'Yes' end as 'did_appointment_occur',
case when isnull(a.aip,0)=0 then 'No' else 'Yes' end as 'aip_received',
case when isnull(a.new_bus,0)=0 then 'No' else 'Yes' end as 'new_business',
appregistration.rid_accountuser as 'applicant_registration_user',
app_ref as 'app_ref',
c.ContactReference as 'contact_ref'
from tbl_apps a 
join tbl_customer c on a.customer_ref=c.client_ref and c.id=@contact_id
left join tbl_grps gstat on a.status=gstat.code_id and gstat.code_group='APPLICANT_STATUS'
left join tbl_grps gmm on a.move_month=gmm.code_id and gmm.code_group='TIMESCALTOMOVE'
left join tbl_grps lr on a.legal_reas=lr.code_id and lr.code_group='LEGAL_REASON'
left join tbl_staff instructed on a.t_neg_no=instructed.emp_id
left join tbl_grps ls on a.legal_stat=ls.code_id and lr.code_group='LEGAL_STATUS'
left join tbl_legal leg on a.legal_cd=leg.legal_id and leg.company is not null 
left join tbl_grps areason on a.fsapptreas=areason.code_id and areason.code_group='APPLICANT_FSAPPTREAS'
left join tbl_staff referred on a.fs_neg_no=referred.emp_id
left join tbl_grps purch on a.PurchasingPositionID=purch.code_id and purch.code_group='APPLICANT_PURCHASING_POSITION'
left join tbl_grps mort on a.mortgagetype=mort.code_id and mort.code_group='MORTGAGE_TYPE'
left join tbl_staff appregistration on a.t_neg_no=appregistration.emp_id
--applicant 2
union 
select
isnull(gstat.code_descr,'') as status,
isnull(gmm.code_descr,'') as 'expected_timescale',
case when isnull(a.HelpToBuy,0) = 0 then 'No' else 'Yes' end as 'interested_in_htb',
case when a.legal_case = 0 then 'No' else 'Yes' end as 'have_services_been_sold',
isnull(lr.code_descr,'') as 'no_reason',
isnull(instructed.rid_accountuser,19443) as 'instructed_by_user',
convert(varchar,a.instdate,23)  as 'date_instructed',
'[' + case when cast(isnull(a.product, '') as varchar) = 1 then '"Selling"'
			when cast(isnull(a.product, '') as varchar) = 2 then '"Selling", "Buying"' 
			else cast('' as varchar) end + ']' as 'product_sold',
isnull(legal_reas,'') as 'legal_status',
isnull(legal_val,0) as'legal_income',
isnull(leg.company,'') as 'conveyancer',
leg.rid_contact as 'conveyancer_rid',
leg.id as 'conveyancer_id',
case when a.fsappt_yn=0 then 'No' else 'Yes' end as 'appointment_made',
isnull(areason.code_descr,'') as 'appointment_reason',
isnull(referred.rid_accountuser,19443) as 'referred_by_user',
isnull(purch.code_descr,'') as 'purchasing_position',
case when len(isnull(A.Lender,''))=0 then 'No' else 'Yes' end as 'spoken_with_lender',
isnull(a.Lender,'') as 'lender_notes',
isnull(a.DepositAmount,0) as 'deposit_available',
isnull(mort.code_descr,'') as 'mortgage_type',
isnull(a.Ratesquoted,0) as 'rates_quoted',
case when isnull(a.ap_occur,0)=0 then 'No' else 'Yes' end as 'did_appointment_occur',
case when isnull(a.aip,0)=0 then 'No' else 'Yes' end as 'aip_received',
case when isnull(a.new_bus,0)=0 then 'No' else 'Yes' end as 'new_business',
appregistration.rid_accountuser as 'applicant_registration_user',
app_ref as 'app_ref',
c.ContactReference as 'contact_ref'
from tbl_apps a 
join tbl_customer c on a.customer_ref1=c.client_ref and c.id=@contact_id
left join tbl_grps gstat on a.status=gstat.code_id and gstat.code_group='APPLICANT_STATUS'
left join tbl_grps gmm on a.move_month=gmm.code_id and gmm.code_group='TIMESCALTOMOVE'
left join tbl_grps lr on a.legal_reas=lr.code_id and lr.code_group='LEGAL_REASON'
left join tbl_staff instructed on a.t_neg_no=instructed.emp_id
left join tbl_grps ls on a.legal_stat=ls.code_id and lr.code_group='LEGAL_STATUS'
left join tbl_legal leg on a.legal_cd=leg.legal_id and leg.company is not null 
left join tbl_grps areason on a.fsapptreas=areason.code_id and areason.code_group='APPLICANT_FSAPPTREAS'
left join tbl_staff referred on a.fs_neg_no=referred.emp_id
left join tbl_grps purch on a.PurchasingPositionID=purch.code_id and purch.code_group='APPLICANT_PURCHASING_POSITION'
left join tbl_grps mort on a.mortgagetype=mort.code_id and mort.code_group='MORTGAGE_TYPE'
left join tbl_staff appregistration on a.t_neg_no=appregistration.emp_id

END

go

USE [InternetDBDev]
GO
/****** Object:  StoredProcedure [dbo].[ROSIE_uspGetContact]    Script Date: 12/12/2018 10:12:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ROSIE_uspGetContact]
	@office_id VARCHAR(4),
	@contact_id int
AS 
BEGIN

SELECT top 1 'Customer Record' as Type, 
	case when p.prop_ref is null then a.app_ref else p.prop_ref end AS reference,
	isnull(nullif(c.addr_1, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.addr_2, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Town, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.county, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Postcode, ''), '') as address_postal,
	case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as def_telephone,
	isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'') as secondtelephone,
	c.id,
	c.client_ref,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname,
    convert(varchar,isnull(dbo.TryConvertDate (c.app_birthdate ),'')) as app_birthdate,
	isnull(c.app_telephone_std,'') as app_telephone_std,
	isnull(c.app_telephone,'') as app_telephone,
	isnull(c.app_mobile,'') as app_mobile,
	isnull(c.app_email,'') as app_email,
	isnull(c.Postcode,'') as Postcode,
	isnull(c.iscompany,0) as iscompany,
	isnull(c.notes,'') as notes,
	isnull(c.EmailNote,'') as EmailNote,
	isnull(c.PhoneNote,'') as PhoneNote,
	isnull(c.MobileNote,'') as MobileNote,
	case when isnull(c.iscompany,0) = 0 then 'person' else 'company' end as recordtype,
	case when isnull(c.iscompany,0) = 0 then null else app_lastname end as companyname
FROM tbl_customer c
     left JOIN tbl_prop p ON c.client_ref= p.customer_ref and p.office_id=@office_id 
	 left JOIN tbl_apps a ON c.client_ref = a.customer_ref
WHERE c.id=@contact_id

END



go
CREATE PROCEDURE [dbo].[ROSIE_uspGetContactNames]
	@contact_id int
AS 
BEGIN

if (select count(*) from tbl_customer where id=@contact_id and iscompany=1)=0
begin
	select id,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname from tbl_customer c where id=@contact_id
end
else
select id,
	'',
	'',
	'',
	'' from tbl_customer c where id=@contact_id
end



go

CREATE PROCEDURE [dbo].[ROSIE_uspGetContactNumbers]
	@contact_id int
AS 
BEGIN
select 	
c.id,
case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as phone_number,
'default' as phone_type,
'1' as phone_primary,
'1' as phone_primary_sms
from tbl_customer c where id=@contact_id
union
select 	
c1.id,
isnull(c1.app_telephone_std,'') + isnull(c1.app_telephone,'') as phone_number,
'home' as phone_type,
'0' as phone_primary,
'0' as phone_primary_sms
from tbl_customer c1 where id=@contact_id

end


go

USE [InternetDBDev]
GO
/****** Object:  StoredProcedure [dbo].[ROSIE_uspGetContacts]    Script Date: 11/12/2018 09:47:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ROSIE_uspGetContacts]
	@office_id VARCHAR(4)
AS 
BEGIN

SELECT 'Vendor1 with Customer Record' as Type, 
	p.prop_ref AS reference,
	isnull(nullif(c.addr_1, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.addr_2, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Town, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.county, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Postcode, ''), '') as address_postal,
	case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as def_telephone,
	isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'') as secondtelephone,
	c.id,
	c.client_ref,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname,
    convert(varchar,isnull(dbo.TryConvertDate (c.app_birthdate ),'')) as app_birthdate,
	isnull(c.app_telephone_std,'') as app_telephone_std,
	isnull(c.app_telephone,'') as app_telephone,
	isnull(c.app_mobile,'') as app_mobile,
	isnull(c.app_email,'') as app_email,
	isnull(c.Postcode,'') as Postcode,
	isnull(c.iscompany,0) as iscompany,
	isnull(c.notes,'') as notes,
	isnull(c.EmailNote,'') as EmailNote,
	isnull(c.PhoneNote,'') as PhoneNote,
	isnull(c.MobileNote,'') as MobileNote,
	case when isnull(c.iscompany,0) = 0 then 'person' else 'company' end as recordtype,
	case when isnull(c.iscompany,0) = 0 then '' else app_lastname end as companyname
FROM tbl_prop p
     INNER JOIN tbl_customer c ON p.customer_ref = c.client_ref
	 left join RosieCustomerMigration m on  c.id=m.CustomerID and m.OfficeID = @office_id
WHERE p.create_d >= DATEADD(YEAR, -7, GETDATE()) AND p.office_id = @office_id and m.rid_contact is null

--AND p.prop_ref IN (SELECT prop_ref FROM tbl_propertiesMigratedFromLive)
UNION
SELECT 'Vendor2 with Customer Record' as Type, 
       p.prop_ref AS reference, 
	isnull(nullif(c.addr_1, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.addr_2, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Town, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.county, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Postcode, ''), '') as address_postal,
	case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as def_telephone,
	isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'') as secondtelephone,
	c.id,
	c.client_ref,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname,
    convert(varchar,isnull(dbo.TryConvertDate (c.app_birthdate ),'')) as app_birthdate,
	isnull(c.app_telephone_std,'') as app_telephone_std,
	isnull(c.app_telephone,'') as app_telephone,
	isnull(c.app_mobile,'') as app_mobile,
	isnull(c.app_email,'') as app_email,
	isnull(c.Postcode,'') as Postcode,
	isnull(c.iscompany,0) as iscompany,
	isnull(c.notes,'') as notes,
	isnull(c.EmailNote,'') as EmailNote,
	isnull(c.PhoneNote,'') as PhoneNote,
	isnull(c.MobileNote,'') as MobileNote,
	case when isnull(c.iscompany,0) = 0 then 'person' else 'company' end as recordtype,
	case when isnull(c.iscompany,0) = 0 then ''  else app_lastname end as companyname
FROM tbl_prop p
     INNER JOIN tbl_fwdaddr fd ON p.prop_ref = fd.prop_ref
     INNER JOIN tbl_customer c ON fd.[customer_ref] = c.client_ref
	 left join RosieCustomerMigration m on  c.id=m.CustomerID and m.OfficeID = @office_id
WHERE p.create_d >= DATEADD(YEAR, -7, GETDATE()) AND p.office_id = @office_id and m.rid_contact is null
--AND p.prop_ref IN (SELECT prop_ref FROM tbl_propertiesMigratedFromLive)
UNION
SELECT 'Applicant1 with Customer Record' as Type, 
       a.app_ref AS reference, 
	isnull(nullif(c.addr_1, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.addr_2, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Town, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.county, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Postcode, ''), '') as address_postal,
	case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as def_telephone,
	isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'') as secondtelephone,
	c.id,
	c.client_ref,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname,
    convert(varchar,isnull(dbo.TryConvertDate (c.app_birthdate ),'')) as app_birthdate,
	isnull(c.app_telephone_std,'') as app_telephone_std,
	isnull(c.app_telephone,'') as app_telephone,
	isnull(c.app_mobile,'') as app_mobile,
	isnull(c.app_email,'') as app_email,
	isnull(c.Postcode,'') as Postcode,
	isnull(c.iscompany,0) as iscompany,
	isnull(c.notes,'') as notes,
	isnull(c.EmailNote,'') as EmailNote,
	isnull(c.PhoneNote,'') as PhoneNote,
	isnull(c.MobileNote,'') as MobileNote,
	case when isnull(c.iscompany,0) = 0 then 'person' else 'company' end as recordtype,
	case when isnull(c.iscompany,0) = 0 then ''  else app_lastname end as companyname
FROM tbl_apps a
     INNER JOIN tbl_Customer c ON a.customer_ref = c.client_ref
	 left join RosieCustomerMigration m on  c.id=m.CustomerID and m.OfficeID = @office_id
WHERE a.create_d >= DATEADD(YEAR, -7, GETDATE()) AND a.office_id  =@office_id and m.rid_contact is null
--AND a.app_ref IN (SELECT app_ref FROM tbl_applicantsMigratedFromLive)
UNION
SELECT 'Applicant2 with Customer Record' as Type, 
       a.app_ref AS reference,
	isnull(nullif(c.addr_1, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.addr_2, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Town, '')  + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.county, '') + CHAR(13)+CHAR(10), '') +
	isnull(nullif(c.Postcode, ''), '') as address_postal,
	case when c.app_mobile is null then (isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'')) else isnull(c.app_mobile,'') end as def_telephone,
	isnull(c.app_telephone_std,'') + isnull(c.app_telephone,'') as secondtelephone,
	c.id,
	c.client_ref,
	isnull(c.app_title,'') as app_title,
	isnull(c.app_forename,'') as app_forename,
	isnull(c.app_middlename,'') as app_middlename,
	isnull(c.app_lastname,'') as app_lastname,
    convert(varchar,isnull(dbo.TryConvertDate (c.app_birthdate ),'')) as app_birthdate,
	isnull(c.app_telephone_std,'') as app_telephone_std,
	isnull(c.app_telephone,'') as app_telephone,
	isnull(c.app_mobile,'') as app_mobile,
	isnull(c.app_email,'') as app_email,
	isnull(c.Postcode,'') as Postcode,
	isnull(c.iscompany,0) as iscompany,
	isnull(c.notes,'') as notes,
	isnull(c.EmailNote,'') as EmailNote,
	isnull(c.PhoneNote,'') as PhoneNote,
	isnull(c.MobileNote,'') as MobileNote,
	case when isnull(c.iscompany,0) = 0 then 'person' else 'company' end as recordtype,
	case when isnull(c.iscompany,0) = 0 then ''  else app_lastname end as companyname
FROM tbl_Customer c
     JOIN tbl_apps a ON c.client_ref = a.customer_ref1
	 left join RosieCustomerMigration m on c.id=m.CustomerID and m.OfficeID = @office_id
WHERE a.create_d >= DATEADD(YEAR, -7, GETDATE()) AND a.office_id = @office_id and m.rid_contact is null
--AND a.app_ref IN (SELECT app_ref FROM tbl_applicantsMigratedFromLive);

END

GO
CREATE PROCEDURE [dbo].[ROSIE_uspGetContactVendor]
	@contact_id int
AS 
BEGIN
--Vendor 1
select 
isnull(gstat.code_descr,'') as status,
isnull(gmm.code_descr,'') as 'expected_timescale',
case when isnull(p.HelpToBuy,0) = 0 then 'No' else 'Yes' end as 'interested_in_htb',
case when isnull(a.legal_case,0) = 0 then 'No' else 'Yes' end as 'have_services_been_sold',
isnull(lr.code_descr,'') as 'no_reason',
isnull(instructed.rid_accountuser,19443) as 'instructed_by_user',
convert(varchar,p.instdate,23)  as 'date_instructed',
'[' + case when cast(isnull(a.product, '') as varchar) = 1 then '"Selling"'
			when cast(isnull(a.product, '') as varchar) = 2 then '"Selling", "Buying"' 
			else cast('' as varchar) end + ']' as 'product_sold',
isnull(ls.code_descr,'') as 'legal_status',
isnull(p.legal_val,0) as'legal_income',
isnull(leg.company,'') as 'conveyancer',
leg.rid_contact as 'conveyancer_rid',
leg.id as 'conveyancer_id',
case when a.fsappt_yn=0 then 'No' else 'Yes' end as 'appointment_made',
isnull(areason.code_descr,'') as 'appointment_reason',
isnull(referred.rid_accountuser,19443) as 'referred_by_user',
isnull(purch.code_descr,'') as 'purchasing_position',
case when len(isnull(A.Lender,''))=0 then 'No' else 'Yes' end as 'spoken_with_lender',
isnull(a.Lender,'') as 'lender_notes',
isnull(a.DepositAmount,0) as 'deposit_available',
isnull(mort.code_descr,'') as 'mortgage_type',
isnull(a.Ratesquoted,0) as 'rates_quoted',
case when isnull(a.ap_occur,0)=0 then 'No' else 'Yes' end as 'did_appointment_occur',
case when isnull(a.aip,0)=0 then 'No' else 'Yes' end as 'aip_received',
case when isnull(a.new_bus,0)=0 then 'No' else 'Yes' end as 'new_business',
appregistration.rid_accountuser as 'applicant_registration_user',
p.prop_ref as 'app_ref',
c.ContactReference as 'contact_ref'
from tbl_prop p
join tbl_customer c on p.customer_ref=c.client_ref and c.id=@contact_id
left join tbl_apps a on a.customer_ref=c.client_ref 
left join tbl_grps gstat on a.status=gstat.code_id and gstat.code_group='APPLICANT_STATUS'
left join tbl_grps gmm on a.move_month=gmm.code_id and gmm.code_group='TIMESCALTOMOVE'
left join tbl_grps lr on a.legal_reas=lr.code_id and lr.code_group='LEGAL_REASON'
left join tbl_staff instructed on a.t_neg_no=instructed.emp_id
left join tbl_grps ls on a.legal_stat=ls.code_id and lr.code_group='LEGAL_STATUS'
left join tbl_legal leg on a.legal_cd=leg.legal_id and leg.company is not null 
left join tbl_grps areason on a.fsapptreas=areason.code_id and areason.code_group='APPLICANT_FSAPPTREAS'
left join tbl_staff referred on a.fs_neg_no=referred.emp_id
left join tbl_grps purch on a.PurchasingPositionID=purch.code_id and purch.code_group='APPLICANT_PURCHASING_POSITION'
left join tbl_grps mort on a.mortgagetype=mort.code_id and mort.code_group='MORTGAGE_TYPE'
left join tbl_staff appregistration on a.t_neg_no=appregistration.emp_id
union
select 
isnull(gstat.code_descr,'') as status,
isnull(gmm.code_descr,'') as 'expected_timescale',
case when isnull(p.HelpToBuy,0) = 0 then 'No' else 'Yes' end as 'interested_in_htb',
case when isnull(a.legal_case,0) = 0 then 'No' else 'Yes' end as 'have_services_been_sold',
isnull(lr.code_descr,'') as 'no_reason',
isnull(instructed.rid_accountuser,19443) as 'instructed_by_user',
convert(varchar,p.instdate,23)  as 'date_instructed',
'[' + case when cast(isnull(a.product, '') as varchar) = 1 then '"Selling"'
			when cast(isnull(a.product, '') as varchar) = 2 then '"Selling", "Buying"' 
			else cast('' as varchar) end + ']' as 'product_sold',
isnull(ls.code_descr,'') as 'legal_status',
isnull(p.legal_val,0) as'legal_income',
isnull(leg.company,'') as 'conveyancer',
leg.rid_contact as 'conveyancer_rid',
leg.id as 'conveyancer_id',
case when a.fsappt_yn=0 then 'No' else 'Yes' end as 'appointment_made',
isnull(areason.code_descr,'') as 'appointment_reason',
isnull(referred.rid_accountuser,19443) as 'referred_by_user',
isnull(purch.code_descr,'') as 'purchasing_position',
case when len(isnull(A.Lender,''))=0 then 'No' else 'Yes' end as 'spoken_with_lender',
isnull(a.Lender,'') as 'lender_notes',
isnull(a.DepositAmount,0) as 'deposit_available',
isnull(mort.code_descr,'') as 'mortgage_type',
isnull(a.Ratesquoted,0) as 'rates_quoted',
case when isnull(a.ap_occur,0)=0 then 'No' else 'Yes' end as 'did_appointment_occur',
case when isnull(a.aip,0)=0 then 'No' else 'Yes' end as 'aip_received',
case when isnull(a.new_bus,0)=0 then 'No' else 'Yes' end as 'new_business',
appregistration.rid_accountuser as 'applicant_registration_user',
p.prop_ref as 'app_ref',
c.ContactReference as 'contact_ref'
from tbl_prop p
     INNER JOIN tbl_fwdaddr fd ON p.prop_ref = fd.prop_ref
join tbl_customer c on fd.customer_ref=c.client_ref and c.id=@contact_id
left join tbl_apps a on a.customer_ref=c.client_ref 
left join tbl_grps gstat on a.status=gstat.code_id and gstat.code_group='APPLICANT_STATUS'
left join tbl_grps gmm on a.move_month=gmm.code_id and gmm.code_group='TIMESCALTOMOVE'
left join tbl_grps lr on a.legal_reas=lr.code_id and lr.code_group='LEGAL_REASON'
left join tbl_staff instructed on a.t_neg_no=instructed.emp_id
left join tbl_grps ls on a.legal_stat=ls.code_id and lr.code_group='LEGAL_STATUS'
left join tbl_legal leg on a.legal_cd=leg.legal_id and leg.company is not null 
left join tbl_grps areason on a.fsapptreas=areason.code_id and areason.code_group='APPLICANT_FSAPPTREAS'
left join tbl_staff referred on a.fs_neg_no=referred.emp_id
left join tbl_grps purch on a.PurchasingPositionID=purch.code_id and purch.code_group='APPLICANT_PURCHASING_POSITION'
left join tbl_grps mort on a.mortgagetype=mort.code_id and mort.code_group='MORTGAGE_TYPE'
left join tbl_staff appregistration on a.t_neg_no=appregistration.emp_id
end



go

CREATE PROCEDURE [dbo].[Rosie_uspInsUpdCustomerRid]

@contact_id int,
@office_id varchar(4),
@rid_contact int,
@etag_contact varchar(50)

AS 
BEGIN

IF NOT EXISTS (
    SELECT NULL FROM dbo.RosieCustomerMigration WHERE CustomerID = @contact_id AND OfficeID = @office_id
)

BEGIN
    
	INSERT INTO dbo.RosieCustomerMigration
    VALUES (@contact_id,@office_id,@rid_contact,@etag_contact)

END

ELSE

BEGIN
	UPDATE RosieCustomerMigration SET rid_contact=@rid_contact, etag_contact=@etag_contact WHERE CustomerID=@contact_id AND OfficeID=@office_id

END

END

go

CREATE FUNCTION [dbo].[TryConvertDate]
(
  @value nvarchar(4000)
)
RETURNS date
AS
BEGIN
  RETURN (SELECT CONVERT(date, CASE 
    WHEN ISDATE(@value) = 1 THEN @value END)
  );
END

go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulius Samoska
-- Create date: 25/05/2016
-- Description:	Gets customer list
-- =============================================
CREATE PROCEDURE [dbo].[ROSIE_uspInsUpdCustomer]  
	-- Add the parameters for the stored procedure here
	@param tinyint = 1,
	@rectype varchar(1) = NULL,
	@CID int = NULL,
	@app_ref varchar(25) = NULL,
	@prop_ref varchar(25) = NULL,
	@risk_level varchar(6) = 'Normal',
	@app_title varchar(20),
	@app_forename varchar(50), 
	@app_middlename varchar(50) = NULL, 
	@app_lastname varchar(50),
	@app_birthdate varchar(10) = NULL,
	@app_telephone_std varchar(10) = NULL, 
	@app_telephone varchar(50) = NULL,
	@app_mobile varchar(50) = NULL, 
	@app_email varchar(200) = NULL,
	@app_ni_license varchar(10) = NULL,
	@app_driving_license varchar(16) = NULL,
	@app_pp_country varchar(3) = NULL,
	@app_pp_expiry varchar(10) = NULL,
	@app_pp_number varchar(44) = NULL,
	@URN varchar(8),
	@user_id varchar(10) = NULL,
	@notes varchar(1000) = NULL,
	@houseNo varchar(5)= NULL,
	@housename varchar(50)= NULL,
	@addr_1 varchar(100)= NULL,
	@addr_2 varchar(100)= NULL,
	@Town varchar(100)= NULL,
	@County varchar(100) =NULL,
	@Postcode varchar(10)= NULL,
	@param1 tinyint = 0,
	@iscompany bit = NULL,
	@emailobt tinyint = NULL,
	@business_type varchar(11) = NULL,
	@agreement varchar(3) = NULL,
	@CompanyNumber varchar(20) = NULL,
	@PhoneNote varchar(50) = NULL,
	@MobileNote varchar(50) = NULL,
	@EmailNote varchar(50) = NULL,
	@BusinessStatus  varchar(20) = NULL,
	@BusinessNOP tinyint = NULL,
	@Status	int = NULL,
	@ExpectedTimescale varchar(2),
	@HelpToBuy bit = NULL,
	@LegalCase bit = NULL,
	@LegalReason int = NULL,
	@LegalInstructedBy varchar(10) = NULL,
	@DateInstructed datetime = NULL,
	@ProductSold tinyint = NULL,
	@LegalStatus int = NULL,
	@LegalIncome numeric(10,2) = NULL,
	@Conveyancer varchar(50) = NULL,
	@Conveyancer_rid int  = NULL,
	@ConveyancerId varchar(10) = NULL,
	@AppointmentMade bit = NULL,
	@AppointmentReason int  = NULL,
	@ReferredByUser varchar(10) = NULL,
	@PurchasingPosition tinyint = NULL,
	@LenderNotes varchar(50) = NULL,
	@DepositAvailable numeric(10,2) = NULL,
	@MortgageType tinyint = NULL,
	@RatesQuoted varchar(250) = NULL,
	@DidAppointmentOccur bit = NULL,
	@AipReceived bit = NULL,
	@NewBusiness bit = NULL,
	@ApplicantRegistratedBy varchar(10) = NULL,
	@UMR varchar(8) = NULL,
	@owner_ref varchar(25) = NULL,
	@contactreference Uniqueidentifier = NULL,
	@contact_rid int  = NULL,
	@contact_etag varchar(50) = NULL,
	@office_id varchar(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*****************************************
	
	RECTYPE:

	A - Applicant
	V - Vendor
	S - Solicitor/Conveyencer

	PARAM:

	1 - insert
	2 - update

	PARAM1:

	0 - update vendor and aplicant
	1 - update vendor
	2 - update applicant

*****************************************/

declare @client_ref varchar(25) = '', 
		@app_count int = 0,
		@app_id int, 
		@app_id_pad varchar(10), 
		@Legal_cd varchar(10), 
		@prev_DidAppointmentOccur bit = 0,
		@prev_AipReceived bit = 0,
		@prev_NewBusiness bit = 0,
		@prev_LegalStatus int,
		@prevprop_LegalStatus int

declare @error int

	IF @param = 1
		-------------------
		-- insert 
		-------------------
		begin
			SET @CID = @@IDENTITY
			SET @client_ref = 'C'+Right(replicate('0',10)+ ltrim(rtrim(cast(@CID as varchar))),10)

			INSERT INTO tbl_customer (	client_ref,
										risk_level, 
										app_title, 
										app_forename, 
										app_middlename, 
										app_lastname, 
										app_birthdate, 
										app_telephone_std, 
										app_telephone, 
										app_mobile, 
										app_email, 
										app_ni_license, 
										app_driving_license, 
										app_pp_country, 
										app_pp_expiry, 
										app_pp_number, 
										URN, 
										create_u, 
										notes,
										houseNo ,
										housename,
										addr_1,
										addr_2,
										Town,
										County ,
										Postcode,
										iscompany,
										emailobt,
										bus_type,
										agreement,
										bus_ref,
										PhoneNote,
										MobileNote,
										EmailNote,
										bus_status,
										bus_nop,
										UMR,
										owner_ref,
										ContactReference)
			VALUES (					@client_ref,
										'Normal', 
										@app_title, 
										@app_forename, 
										@app_middlename, 
										@app_lastname, 
										@app_birthdate, 
										@app_telephone_std, 
										@app_telephone, 
										@app_mobile, 
										@app_email, 
										@app_ni_license, 
										@app_driving_license, 
										@app_pp_country, 
										@app_pp_expiry, 
										@app_pp_number, 
										@URN, 
										@user_id, 
										@notes,
										@houseNo ,
										@housename,
										@addr_1,
										@addr_2,
										@Town,
										@County ,
										@Postcode,
										@iscompany,
										@emailobt,
										@business_type,
										@agreement,
										@CompanyNumber,
										@PhoneNote,
										@MobileNote,
										@EmailNote,
										@BusinessStatus,
										@BusinessNOP,
										@UMR,
										@owner_ref,
										@ContactReference)
			
			UPDATE	tbl_customer
			SET		bus_name = CASE WHEN iscompany = 1 THEN app_lastname ELSE bus_name END,
					bus_postcode = CASE WHEN iscompany = 1 THEN Postcode ELSE bus_postcode END
			where id = @client_ref

			SELECT @app_count = COUNT(*)
			FROM tbl_Apps
			WHERE app_ref = @app_ref

			IF (@rectype = 'A' and @app_count = 0)
			BEGIN

				exec dbo.uspGetNextID_Applicant @office_id, @app_id output, @app_id_pad output

				select @app_ref = case when upper(rtrim(org_id)) = 'FIN' then 'CWR'
                                       when upper(rtrim(org_id)) = 'BAI' then 'BJB' 
									   else upper(rtrim(org_id)) end + rtrim(@office_id) + @app_id_pad
                from   dbo.tbl_off
                where  office_id = @office_id

				SELECT @Legal_cd = legal_id
				FROM tbl_legal
				WHERE rid_contact = @Conveyancer_rid
				AND company is not null 

				INSERT INTO tbl_apps  ( app_ref,
										app_id,
										office_id,
				 						neg,
				 						prop_ref,
				 						title_1,
				 						first_1,
           		 						surn_1,
           		 						telnoh_1,
           		 						telnow_1,
           		 						telnom_1,
           		 						telnof_1,
           		 						addr1_1,
           		 						addr2_1,
           		 						town_1,
           		 						county_1,
           		 						postcode_1,
          		 						move_month,
          		 						prop_type,
          		 						bedrooms,
         		 						receptions,
         		 						post_town,
          		 						county,
          		 						post_code,
          		 						source,
          		 						special,
          		 						status,
          		 						free_val,
          		 						mort_req,
          		 						referral,
          		 						price_star,
          		 						price_end,
          		 						fa_apdate,
          		 						sell_off,
          		 						create_d,
          		 						create_u,
          		 						update_d,
         		 						update_u,
          		 						selling_ea,
          		 						email_1,
          		 						bypost,
          		 						byemail,
          		 						bytel,
          		 						upd_flag,
          		 						attempts,
          		 						apparch,
          		 						fsnotreqd,
          		 						fsnotrefd,
          		 						internat,
          		 						intonly,
          		 						intarea,
          		 						legal_cd,
          		 						legal_cont,
          		 						legal_case,
         		 						legal_stat,
         		 						legal_reas,
          		 						legal_val,
          		 						fsappt_yn,
          		 						fsapptreas,
          		 						ap_occur,
          		 						aip,
          		 						new_bus,
          		 						vendor,
          		 						vend_prop,
          		 						besttime,
          		 						cont_pref,
          		 						dpa_optin,
          		 						t_neg_no,
          		 						fs_neg_no,
          		 						l_scale,
          		 						l_inv_status,
          		 						instdate,
          		 						exchdate,
         		 						comp_date,
         		 						tenure,
          		 						purchprice,
         		 						newbuild,
         		 						newadd,
          		 						newpc,
          		 						launder,
          		 						product,
          		 						unsubscrib,
          		 						l_online,
          		 						option1,
          		 						prime_prot,
          		 						locked,
          		 						pc,
          		 						usr,
          		 						HelpToBuy,
          		 						FromWeb,
          		 						faceappt,
          		 						telappt,
          		 						BSTempid,
          		 						FSadempid,
          		 						ApptOffice,
         		 						PurchasingPositionID,
          		 						SourceID,
          		 						Motivated,
          		 						SourceOfFunds,
          		 						budgetprice,
          		 						budgetpreset,
          		 						mortgagetype,
          		 						DepositAmount,
          		 						Ratesquoted,
          		 						Lender,
         		 						mobnonote,
          		 						telnonote,
          		 						worknonote,
          		 						URN,
          		 						customer_ref,
          		 						iscompany,
          		 						EmailNote,
          		 						LOTS,
          		 						ContactReference,
          		 						rid_contact,
          		 						etag_contact,
          		 						rid_matchprofile,
          		 						etag_matchprofile)
							VALUES (
									    @app_ref,
										@app_id,
										@office_id,
				 						@user_id,
				 						'',
				 						@app_title,
				 						@app_forename,
           		 						@app_lastname,
           		 						@app_telephone,
           		 						'',
           		 						@app_mobile,
           		 						'',
           		 						RTRIM(CASE WHEN ISNULL(@housename,'') != '' THEN @housename + ', ' ELSE '' END + 
											  CASE WHEN ISNULL(@houseno,'') != '' THEN @houseno + ' ' ELSE '' END +
											  ISNULL(@addr_1,'')),
           		 						@addr_2,
           		 						@town,
           		 						@county,
           		 						@postcode,
          		 						@ExpectedTimescale,
          		 						0,
          		 						0,
         		 						0,
         		 						'',
          		 						'',
          		 						'',
          		 						'From Rosie', -- source
          		 						'', -- special
          		 						ISNULL(@Status,0), -- status (set as PROPERTY TO SELL?)
          		 						0, -- free_val (set as No)
          		 						0, -- mort_req (set as No)
          		 						0, -- referral (set as No)
          		 						0, -- price_star
          		 						0, -- price_end
          		 						'', -- fa_apdate,
          		 						'', -- sell_off,
          		 						getdate(),
          		 						'ROSIE',
          		 						'',
         		 						'',
          		 						'', -- selling_ea
          		 						@app_email,
          		 						0, -- bypost
          		 						0, -- byemail
          		 						0, -- bytel
          		 						0, -- upd_flag
          		 						0, -- attempts
          		 						0, -- apparch
          		 						0, -- fsnotreqd
          		 						0, -- fsnotrefd
          		 						0, -- internat
          		 						0, -- intonly
          		 						0, -- intarea
          		 						ISNULL(@Legal_cd,''), -- legal_cd
          		 						'', -- legal_cont
          		 						ISNULL(@LegalCase,''), -- legal_case
         		 						ISNULL(@LegalStatus,''), -- legal_stat
         		 						ISNULL(@LegalCase,''), -- legal_reas
          		 						ISNULL(@LegalIncome,0), -- legal_val
          		 						ISNULL(@AppointmentMade,0), -- fsappt_yn,
          		 						ISNULL(@AppointmentReason,0), -- fsapptreas,
          		 						ISNULL(@DidAppointmentOccur,0), -- ap_occur,
          		 						ISNULL(@AipReceived,0), -- aip,
          		 						ISNULL(@NewBusiness,0), -- new_bus,
          		 						0, -- vendor,
          		 						'', -- vend_prop,
          		 						0, -- besttime,
          		 						0, -- cont_pref,
          		 						0, -- dpa_optin,
          		 						ISNULL(@LegalInstructedBy,''), -- t_neg_no,
          		 						ISNULL(@ReferredByUser,''), -- fs_neg_no,
          		 						'', -- l_scale,
          		 						0, -- l_inv_status,
          		 						ISNULL(@DateInstructed,''), -- instdate,
          		 						'', -- exchdate,
         		 						'', -- comp_date,
         		 						'', -- tenure,
          		 						'', -- purchprice,
         		 						'', -- newbuild,
         		 						'', -- newadd,
          		 						'', -- newpc,
          		 						0, -- launder,
          		 						ISNULL(@ProductSold,0), -- product,
          		 						0, -- unsubscrib,
          		 						0, -- l_online,
          		 						0, -- option1,
          		 						0, -- prime_prot,
          		 						'ROSIE',
          		 						'',
          		 						'ROSIE',
          		 						@HelpToBuy, -- HelpToBuy,
          		 						0, -- FromWeb,
          		 						0, -- faceappt,
          		 						0, -- telappt,
          		 						'', -- BSTempid,
          		 						'', -- FSadempid,
          		 						'', -- ApptOffice,
         		 						ISNULL(@PurchasingPosition,0), -- PurchasingPositionID,
          		 						0, -- SourceID,
          		 						1, -- Motivated,
          		 						'', -- SourceOfFunds,
          		 						'', -- budgetprice,
          		 						'', -- budgetpreset,
          		 						@MortgageType, -- mortgagetype,
          		 						ISNULL(@DepositAvailable,0), -- DepositAmount,
          		 						ISNULL(@RatesQuoted,''), -- Ratesquoted,
          		 						ISNULL(@LenderNotes,''), -- Lender,
         		 						NULL, -- mobnonote,
          		 						NULL, -- telnonote,
          		 						'', -- worknonote,
          		 						'', -- URN,
          		 						@client_ref,
          		 						0, -- iscompany,
          		 						'', -- EmailNote,
          		 						0, -- LOTS,
          		 						NULL, -- ContactReference,
          		 						@contact_rid,
          		 						@contact_etag,
          		 						NULL, -- rid_matchprofile,
          		 						NULL -- tag_matchprofile)
										)
			END
		end 



	IF @param = 2
			-------------------
			-- UPDATE 
			-------------------
			begin
				BEGIN TRANSACTION
					
					SELECT @error = @@error

					UPDATE	tbl_customer 
					SET		risk_level = isnull(@risk_level,risk_level) ,
							app_title =  @app_title,
							app_forename =  @app_forename,
							app_middlename = @app_middlename, 
							app_lastname = @app_lastname, 
							app_birthdate = @app_birthdate, 
							app_telephone_std = @app_telephone_std, 
							app_telephone = @app_telephone, 
							app_mobile = @app_mobile, 
							app_email = @app_email, 
							app_ni_license = @app_ni_license, 
							app_driving_license = @app_driving_license, 
							app_pp_country = @app_pp_country, 
							app_pp_expiry = @app_pp_expiry, 
							app_pp_number = @app_pp_number, 
							URN = @URN, 
							update_d = getdate(),
							update_u = @user_id,
							notes = @notes,
							houseNo = @houseNo,
							housename = @housename,
							addr_1 = @addr_1,
							addr_2 = @addr_2,
							Town = @Town,
							County = @County,
							Postcode = @Postcode,
							iscompany = @iscompany,
							emailobt = @emailobt,
							bus_type = @business_type,
							agreement = @agreement,
							bus_ref = @CompanyNumber,
							PhoneNote = @PhoneNote,
							MobileNote = @MobileNote,
							EmailNote = @EmailNote,
							bus_name = CASE WHEN iscompany = 1 THEN app_lastname ELSE bus_name END,
							bus_postcode = CASE WHEN iscompany = 1 THEN Postcode ELSE bus_postcode END,
							bus_status = @BusinessStatus,
							bus_nop = @BusinessNOP,
							UMR = @UMR,
							owner_ref = @owner_ref

					WHERE	ID = @CID
				
					SELECT @error = @@error
	
					IF @error = 0 
						begin
							-- get client ref

							DECLARE @customer_ref varchar(25) = NULL
							SELECT @customer_ref = client_ref,@client_ref = client_ref
							FROM tbl_customer WITH (NOLOCK)
							where id = @CID

							SELECT @error = @@error
						end
			
		
				/*****************************************

					UPDATE VENDOR AND APPLICANT

				*******************************************/

				IF @error = 0 

					BEGIN
							-- Update vendor

							SELECT	@prevprop_LegalStatus = legal_stat
							FROM	tbl_apps
							WHERE	customer_ref = @customer_ref
							AND		prop_ref = @prop_ref
					
							UPDATE tbl_prop
							SET		vtitle =  @app_title,
									vinit = left(@app_forename,1),
									vfirstname =  @app_forename,
									cont_name = @app_lastname, 
									cont_telno = rtrim(isnull(@app_telephone_std,'')) + ' ' + rtrim(isnull(@app_telephone,'')), 
									cont_mobno = @app_mobile, 
									emailobt = @emailobt,
									vemail = @app_email, 
									--update_d = getdate(),
									--update_u = @user_id,
									vaddr_1 = RTRIM(CASE WHEN ISNULL(@housename,'') != '' THEN @housename + ', ' ELSE '' END + 
											  CASE WHEN ISNULL(@houseno,'') != '' THEN @houseno + ' ' ELSE '' END +
											  ISNULL(@addr_1,'')),
									vaddr_2 = @addr_2,
									vTown = @Town,
									vCounty = @County,
									vpostcode = @Postcode,
									iscompany = @iscompany,
									mobnonote = @MobileNote,
									telnonote = @PhoneNote,
									EmailNote = @EmailNote,
									Legal_case = @LegalCase,
									Legal_reas = @LegalReason,
									t_neg_no = @LegalInstructedBy,
									instdate = @DateInstructed,
									product = @ProductSold,
									legal_stat = @LegalStatus,
									legal_val = @LegalIncome,
									legal_cd = @legal_cd
							WHERE	customer_ref = @customer_ref
							AND		prop_ref = @prop_ref

							SELECT @error = @@error
					END
				
					-- Second vendor

					IF @error = 0 
						begin
							UPDATE tbl_fwdaddr
							SET		vtitle =  @app_title,
									vinit = left(@app_forename,1),
									vfirstname =  @app_forename,
									cont_name = @app_lastname, 
									cont_telno = rtrim(isnull(@app_telephone_std,'')) + ' ' + rtrim(isnull(@app_telephone,'')), 
									cont_mobno = @app_mobile, 
									emailobt = @emailobt,
									vemail = @app_email, 
									--update_u = @user_id,
									--vaddr_1 = (rtrim(isnull(@houseNo,'')) + ' '+ rtrim(isnull(@housename,''))) + ' ' + rtrim(isnull(@addr_1,'')),
									vaddr_1 = rtrim(isnull(@addr_1,'')),
									vaddr_2 = @addr_2,
									vTown = @Town,
									vCounty = @County,
									vpostcode = @Postcode,
									iscompany = @iscompany,
									mobnonote = @MobileNote,
									telnonote = @PhoneNote,
									EmailNote = @EmailNote
							WHERE	customer_ref = @customer_ref

							SELECT @error = @@error
						end 
							
					IF @error = 0 
						begin 
							-- Update aplicant

							SELECT	@prev_LegalStatus = legal_stat,
									@prev_DidAppointmentOccur = ap_occur,
									@prev_AipReceived = aip,
									@prev_NewBusiness = new_bus
							FROM	tbl_apps
							WHERE	customer_ref = @customer_ref
							AND		app_ref = @app_ref
					
							UPDATE tbl_apps
							SET		title_1 =  @app_title,
									first_1 =  @app_forename,
									surn_1 = @app_lastname, 
									telnoh_1 = rtrim(isnull(@app_telephone_std,'')) + ' ' + rtrim(isnull(@app_telephone,'')), 
									telnom_1 = @app_mobile, 
									email_1 = @app_email, 
									addr1_1 = RTRIM(CASE WHEN ISNULL(@housename,'') != '' THEN @housename + ', ' ELSE '' END + 
											  CASE WHEN ISNULL(@houseno,'') != '' THEN @houseno + ' ' ELSE '' END +
											  ISNULL(@addr_1,'')),
									addr1_2 = @addr_2,
									town_1 = @Town,
									county_1 = @County,
									postcode_1 = @Postcode,
									iscompany = @iscompany,
									mobnonote = @MobileNote,
									telnonote = @PhoneNote,
									EmailNote = @EmailNote,
									Status = @Status,
									move_month = @ExpectedTimescale,
									HelpToBuy = @HelpToBuy,
									Legal_case = @LegalCase,
									Legal_reas = @LegalReason,
									t_neg_no = @LegalInstructedBy,
									instdate = @DateInstructed,
									product = @ProductSold,
									legal_stat = @LegalStatus,
									legal_val = @LegalIncome,
									legal_cd = @legal_cd,
									fsappt_yn = @AppointmentMade,
									fsapptreas = @AppointmentReason,
									fs_neg_no = @ReferredByUser,
									PurchasingPositionID = @PurchasingPosition,
									Lender = @LenderNotes,
									DepositAmount = @DepositAvailable,
									mortgagetype = @MortgageType,
									Ratesquoted = @RatesQuoted,
									ap_occur = @DidAppointmentOccur,
									aip = @AipReceived,
									new_bus = @NewBusiness
							WHERE	customer_ref = @customer_ref
							AND		app_ref = @app_ref

							SELECT @error = @@error
						end 

					IF @error = 0 
						begin

							UPDATE tbl_apps
							SET		title_2 =  @app_title,
									first_2 =  @app_forename,
									surn_2 = @app_lastname, 
									telnoh_2 = rtrim(isnull(@app_telephone_std,'')) + ' ' + rtrim(isnull(@app_telephone,'')), 
									telnom_2 = @app_mobile, 
									email_2 = @app_email, 
									addr1_1 = RTRIM(CASE WHEN ISNULL(@housename,'') != '' THEN @housename + ', ' ELSE '' END + 
											  CASE WHEN ISNULL(@houseno,'') != '' THEN @houseno + ' ' ELSE '' END +
											  ISNULL(@addr_1,'')),
									addr2_2 = @addr_2,
									town_2 = @Town,
									county_2 = @County,
									postcode_2 = @Postcode,
									mobnonote2 = @MobileNote,
									telnonote2 = @PhoneNote,
									EmailNote2 = @EmailNote,
									Status = @Status,
									move_month = @ExpectedTimescale,
									HelpToBuy = @HelpToBuy,
									Legal_case = @LegalCase,
									Legal_reas = @LegalReason,
									t_neg_no = @LegalInstructedBy,
									instdate = @DateInstructed,
									product = @ProductSold,
									legal_stat = @LegalStatus,
									legal_val = @LegalIncome,
									legal_cd = @legal_cd,
									fsappt_yn = @AppointmentMade,
									fsapptreas = @AppointmentReason,
									fs_neg_no = @ReferredByUser,
									PurchasingPositionID = @PurchasingPosition,
									Lender = @LenderNotes,
									DepositAmount = @DepositAvailable,
									mortgagetype = @MortgageType,
									Ratesquoted = @RatesQuoted,
									ap_occur = @DidAppointmentOccur,
									aip = @AipReceived,
									new_bus = @NewBusiness
							WHERE	customer_ref1 = @customer_ref
							AND		app_ref = @app_ref

							SELECT @error = @@error
						end
	
			-- Complete transaction

					IF @error = 0
						BEGIN
							COMMIT TRANSACTION
						END
					ELSE
						BEGIN
							ROLLBACK TRANSACTION
						END

			END	

			IF NOT EXISTS (
				SELECT NULL FROM dbo.RosieCustomerMigration WHERE CustomerID = @CID AND OfficeID = @office_id
			)				
			BEGIN    
				INSERT INTO dbo.RosieCustomerMigration VALUES (@CID,@office_id,@contact_rid,@contact_etag)
			END
			ELSE
			BEGIN
				UPDATE RosieCustomerMigration SET rid_contact=@contact_rid, etag_contact=@contact_etag WHERE CustomerID=@CID AND OfficeID=@office_id

			END

			-- Section to set up events for KPI reporting
			--
			-- K069 FS First Appointments (Count)
			--
			IF ISNULL(@prev_DidAppointmentOccur,0) = 0 AND @DidAppointmentOccur = 1
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 88, 
				 'FS Appt Taken Place Indicator Set', 
				 0,
				 NULL,
				 '',
				 @ReferredByUser
				);
			END

			--
			-- K122 FS Number of AIPs (Count)
			--
			IF ISNULL(@prev_AipReceived,0) = 0 AND @AipReceived = 1
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 84, 
				 'FS AIP Indicator Set', 
				 0,
				 NULL,
				 '',
				 @ReferredByUser
				);
			END

			--
			-- SignUp FS New Business Written (Count)
			--
			IF ISNULL(@prev_NewBusiness,0) = 0 AND @NewBusiness = 1
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 86, 
				 'FS Sign-Up Indicator Set', 
				 0,
				 NULL,
				 '',
				 @ReferredByUser
				);
			END

			--
			-- K803 Legal Instructions (Count) **** APPLICANT ****
			-- K804 Legal Instructions (Value) **** APPLICANT ****
			--
			IF (ISNULL(@prev_LegalStatus,0) = 0 AND @LegalStatus = 1)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@app_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 80, 
				 'Legal Instruction Set', 
				 0,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K803 Legal Instructions (Count) **** PROPERTY ****
			-- K804 Legal Instructions (Value) **** PROPERTY ****
			--
			IF (ISNULL(@prevprop_LegalStatus,0) = 0 AND @LegalStatus = 1)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@prop_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 1, 
				 @prop_ref, 
				 GETDATE(), 
				 80, 
				 'Legal Instruction Set', 
				 0,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K298 Legal Gross Sales (Count) **** APPLICANT ****
			-- K299 Legal Gross Sales (Value) **** APPLICANT ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,3,4,5,6) AND @LegalStatus = 2)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@app_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 3002, 
				 'Legal Status Change To Gross Sale', 
				 1,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K298 Legal Gross Sales (Count) **** PROPERTY ****
			-- K299 Legal Gross Sales (Value) **** PROPERTY ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,3,4,5,6) AND @LegalStatus = 2)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@prop_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 1, 
				 @prop_ref, 
				 GETDATE(), 
				 3002, 
				 'Legal Status Change To Gross Sale', 
				 1,
				 0,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K285 Legal Aborts (Count) **** APPLICANT ****
			-- K286 Legal Aborts (Value) **** APPLICANT ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,2,3,5,6) AND @LegalStatus = 4)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@app_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 3002, 
				 'Legal Status Change To Aborted Gross Sale', 
				 2,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K285 Legal Aborts (Count) **** PROPERTY ****
			-- K286 Legal Aborts (Value) **** PROPERTY ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,2,3,5,6) AND @LegalStatus = 4)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@prop_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 1, 
				 @prop_ref, 
				 GETDATE(), 
				 3002, 
				 'Legal Status Change To Aborted Gross Sale', 
				 1,
				 0,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K262 Legal Completions (Count) **** APPLICANT ****
			-- K263 Legal Completions (Value) **** APPLICANT ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,2,4,5,6) AND @LegalStatus = 3)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@app_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 2, 
				 @app_ref, 
				 GETDATE(), 
				 3003, 
				 'Legal Status Change To Completed (Legal Exchange)', 
				 2,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			--
			-- K262 Legal Completions (Count) **** PROPERTY ****
			-- K263 Legal Completions (Value) **** PROPERTY ****
			--
			IF (ISNULL(@prev_LegalStatus,0) in (1,2,4,5,6) AND @LegalStatus = 3)
				AND ISNULL(@LegalIncome,0) > 0
				AND ISNULL(@prop_ref, '') != ''
			BEGIN
				INSERT INTO tbl_track
				(track_id, 
				 track_type, 
				 track_ref, 
				 event_date, 
				 event_id, 
				 event_data, 
				 event_val,
				 event_val2,
				 neg_no,
				 update_u
				)
				VALUES
				(RIGHT(NEWID(), 10), 
				 1, 
				 @prop_ref, 
				 GETDATE(), 
				 3003, 
				 'Legal Status Change To Completed (Legal Exchange)', 
				 2,
				 NULL,
				 '',
				 @LegalInstructedBy
				);
			END

			-- Return Result 

			SELECT  @client_ref AS result
			
END

go

USE [InternetDBDev]
GO
/****** Object:  StoredProcedure [dbo].[ROSIE_GetApplicants]    Script Date: 06/12/2018 16:50:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ROSIE_GetApplicants]
	@OfficeID varchar(4)
AS
SELECT 'Applicant1 with Customer Record' as Type, 
a.prop_ref,a.title_1,a.surn_1,a.prop_type,a.bedrooms,a.receptions,a.post_town,a.county,a.post_code,a.price_star,a.price_end,
g.code_descr,
m.rid_contact,
m.etag_contact,
b.beds_start,
b.beds_end,
a.sqlid
FROM tbl_apps a
     INNER JOIN tbl_Customer c ON a.customer_ref = c.client_ref
	 left join RosieCustomerMigration m on  c.id=m.CustomerID and m.OfficeID =  @OfficeID and m.rid_contact is not null
	 inner join tbl_grps g on a.prop_type=g.code_id and g.code_group='PROPERTY_TYPE'
	 left join tbl_beds b on a.bedrooms=b.beds_id
WHERE a.create_d >= DATEADD(YEAR, -7, GETDATE()) AND a.office_id = @OfficeID and a.rid_matchprofile is null
and a.prop_type not in (99,90)
UNION
SELECT 'Applicant2 with Customer Record' as Type, 
a1.prop_ref,a1.title_1,a1.surn_1,a1.prop_type,a1.bedrooms,a1.receptions,a1.post_town,a1.county,a1.post_code,a1.price_star,a1.price_end,
g1.code_descr,
m1.rid_contact,
m1.etag_contact,
b1.beds_start,
b1.beds_end,
a1.sqlid
FROM tbl_apps a1
     INNER JOIN tbl_Customer c1 ON a1.customer_ref1 = c1.client_ref
	 left join RosieCustomerMigration m1 on  c1.id=m1.CustomerID and m1.OfficeID =  @OfficeID and m1.rid_contact is not null
	 inner join tbl_grps g1 on a1.prop_type=g1.code_id and g1.code_group='PROPERTY_TYPE'
	 left join tbl_beds b1 on a1.bedrooms=b1.beds_id
WHERE a1.create_d >= DATEADD(YEAR, -7, GETDATE()) AND a1.office_id = @OfficeID  and a1.rid_matchprofile is null
and a1.prop_type not in (99,90)


GO

CREATE PROCEDURE [dbo].[ROSIE_IDBSV4_WriteDMARecipient]
	@dma_id INT,
	@office_id NVARCHAR(4),
	@title NVARCHAR(8),
	@forename NVARCHAR(50),
	@surname NVARCHAR(50),
	@houseno NVARCHAR(5),
	@housename NVARCHAR(50),
	@addr_1 NVARCHAR(100),
	@addr_2 NVARCHAR(100),
	@town NVARCHAR(100),
	@county NVARCHAR(100),
	@postcode NVARCHAR(10),
	@phone1 NVARCHAR(50),
	@phone1primary BIT,
	@phone2 NVARCHAR(50),
	@phone2primary BIT,
	@phone3 NVARCHAR(50),
	@phone3primary BIT,
	@phone4 NVARCHAR(50),
	@phone4primary BIT,
	@phone5 NVARCHAR(50),
	@phone5primary BIT,
	@phone6 NVARCHAR(50),
	@phone6primary BIT,
	@phone7 NVARCHAR(50),
	@phone7primary BIT,
	@phone8 NVARCHAR(50),
	@phone8primary BIT,
	@email1 NVARCHAR(100),
	@email1primary BIT,
	@email2 NVARCHAR(100),
	@email2primary BIT,
	@email3 NVARCHAR(100),
	@email3primary BIT,
	@email4 NVARCHAR(100),
	@email4primary BIT,
	@estateagent NVARCHAR(50),
	@type NVARCHAR(25),
	@housevalue INT,
	@status NVARCHAR(100),
	@rec_type INT,
	@rid_marketlead INT,
	@etag_marketlead NVARCHAR(72),
	@create_u	NVARCHAR(8),
	@update_d	DATETIME,
	@update_u	NVARCHAR(8),
	@propURL NVARCHAR(250),
	@rid_local_agency INT,
	@system_record_state NVARCHAR(100)
AS

DECLARE @DMA_PhoneNo NVARCHAR(50) = NULL, @DMA_Phone2 NVARCHAR(50) = NULL, @DMA_Phone3 NVARCHAR(50) = NULL, @DMA_EmailAddr NVARCHAR(100) = NULL

IF (ISNULL(@phone1primary, 0) = 1 AND ISNULL(RTRIM(@phone1), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone1))
ELSE IF (ISNULL(@phone2primary, 0) = 1 AND ISNULL(RTRIM(@phone2), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone2))
ELSE IF (ISNULL(@phone3primary, 0) = 1 AND ISNULL(RTRIM(@phone3), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone3))
ELSE IF (ISNULL(@phone4primary, 0) = 1 AND ISNULL(RTRIM(@phone4), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone4))
ELSE IF (ISNULL(@phone5primary, 0) = 1 AND ISNULL(RTRIM(@phone5), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone5))
ELSE IF (ISNULL(@phone6primary, 0) = 1 AND ISNULL(RTRIM(@phone6), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone6))
ELSE IF (ISNULL(@phone7primary, 0) = 1 AND ISNULL(RTRIM(@phone7), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone7))
ELSE IF (ISNULL(@phone8primary, 0) = 1 AND ISNULL(RTRIM(@phone8), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone8))

IF (@DMA_PhoneNo IS NULL)
BEGIN
    IF (ISNULL(RTRIM(@phone1), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone1))
    ELSE IF (ISNULL(RTRIM(@phone2), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone2))
    ELSE IF (ISNULL(RTRIM(@phone3), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone3))
    ELSE IF (ISNULL(RTRIM(@phone4), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone4))
    ELSE IF (ISNULL(RTRIM(@phone5), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone5))
    ELSE IF (ISNULL(RTRIM(@phone6), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone6))
    ELSE IF (ISNULL(RTRIM(@phone7), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone7))
    ELSE IF (ISNULL(RTRIM(@phone8), '') <> '') SET @DMA_PhoneNo = RTRIM(LTRIM(@phone8))
END

IF (RTRIM(LTRIM(@phone1)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone1), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone1))
ELSE IF (RTRIM(LTRIM(@phone2)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone2), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone2))
ELSE IF (RTRIM(LTRIM(@phone3)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone3), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone3))
ELSE IF (RTRIM(LTRIM(@phone4)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone4), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone4))
ELSE IF (RTRIM(LTRIM(@phone5)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone5), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone5))
ELSE IF (RTRIM(LTRIM(@phone6)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone6), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone6))
ELSE IF (RTRIM(LTRIM(@phone7)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone7), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone7))
ELSE IF (RTRIM(LTRIM(@phone8)) <> @DMA_PhoneNo AND ISNULL(RTRIM(@phone8), '') <> '') SET @DMA_Phone2 = RTRIM(LTRIM(@phone8))

IF (RTRIM(LTRIM(@phone1)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone1)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone1), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone1))
ELSE IF (RTRIM(LTRIM(@phone2)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone2)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone2), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone2))
ELSE IF (RTRIM(LTRIM(@phone3)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone3)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone3), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone3))
ELSE IF (RTRIM(LTRIM(@phone4)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone4)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone4), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone4))
ELSE IF (RTRIM(LTRIM(@phone5)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone5)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone5), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone5))
ELSE IF (RTRIM(LTRIM(@phone6)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone6)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone6), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone6))
ELSE IF (RTRIM(LTRIM(@phone7)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone7)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone7), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone7))
ELSE IF (RTRIM(LTRIM(@phone8)) <> @DMA_PhoneNo AND RTRIM(LTRIM(@phone8)) <> @DMA_Phone2 AND ISNULL(RTRIM(@phone8), '') <> '') SET @DMA_Phone3 = RTRIM(LTRIM(@phone8))

IF (ISNULL(@email1primary, 0) = 1 AND ISNULL(RTRIM(@email1), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email1))
ELSE IF (ISNULL(@email2primary, 0) = 1 AND ISNULL(RTRIM(@email2), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email2))
ELSE IF (ISNULL(@email3primary, 0) = 1 AND ISNULL(RTRIM(@email3), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email3))
ELSE IF (ISNULL(@email4primary, 0) = 1 AND ISNULL(RTRIM(@email4), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email4))

IF (@DMA_EmailAddr IS NULL)
BEGIN
    IF (ISNULL(RTRIM(@email1), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email1))
    ELSE IF (ISNULL(RTRIM(@email2), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email2))
    ELSE IF (ISNULL(RTRIM(@email3), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email3))
    ELSE IF (ISNULL(RTRIM(@email4), '') <> '') SET @DMA_EmailAddr = RTRIM(LTRIM(@email4))
END

SET @office_id = RTRIM(LTRIM(@office_id))
SET @title = RTRIM(LTRIM(@title))
SET @forename = RTRIM(LTRIM(@forename))
SET @surname = RTRIM(LTRIM(@surname))
SET @houseno = RTRIM(LTRIM(@houseno))
SET @housename = RTRIM(LTRIM(@housename))
SET @addr_1 = RTRIM(LTRIM(@addr_1))
SET @addr_2 = RTRIM(LTRIM(@addr_2))
SET @town = RTRIM(LTRIM(@town))
SET @county = RTRIM(LTRIM(@county))
SET @postcode = RTRIM(LTRIM(@postcode))
SET @estateagent = RTRIM(LTRIM(@estateagent))
SET @type = RTRIM(LTRIM(@type))
SET @status = RTRIM(LTRIM(@status))

DECLARE @pass2buzz datetime = NULL,
	@neg_no NVARCHAR(10) = NULL,
	@landlordreferral TINYINT = NULL,
	@houseno1 NVARCHAR(5) = NULL,
	@housename1 NVARCHAR(50) = NULL,
	@addr_11 NVARCHAR(100) = NULL,
	@addr_21 NVARCHAR(100) = NULL,
	@town1 NVARCHAR(100) = NULL,
	@county1 NVARCHAR(100) = NULL,
	@postcode1 NVARCHAR(10) = NULL,
	@phoneno1 NVARCHAR(50) = NULL,
	@emailaddr1 NVARCHAR(100) = NULL,
	@title1 NVARCHAR(8) = NULL,
	@forename1 NVARCHAR(50) = NULL,
	@surname1 NVARCHAR(50) = NULL,
	@neg_no_1 NVARCHAR(10) = NULL,
	@securedtxt NVARCHAR(25) = NULL,
	@board BIT = NULL,
	@POMDATE DATETIME = NULL,
	@urn NVARCHAR(8) = NULL,
	@vacant BIT = NULL,
	@umr NVARCHAR(8) = NULL,
	@tenanted BIT = NULL, 
	@buzzbranch INT = 0,
	@orgid NVARCHAR(3),
	@phoneins INT,
	@SourceFile NVARCHAR(20) = 'Rosie',
	@LocalAgencyID INT = NULL,
	@DMArid_local_agency INT = NULL,
	@BranchAddedPhone BIT,
	@BranchAddedHouseNoName BIT

SELECT @orgid = org_id
FROM	tbl_off
WHERE office_id = @office_id

IF @surname IN ('Occupier', 'Homeowner') OR LEN(@surname) < 3
BEGIN
    SELECT @title = 'The'
    SELECT @forename = ''
    SELECT @surname = 'Homeowner'
END

DECLARE @error INT,
    @write_result CHAR(1), /* I - Insert, U - Update, D - Delete, F - Failed */
    @dma_status CHAR(1),
    @import_status CHAR(1)

SELECT @LocalAgencyID = ID, @DMArid_local_agency = rid_local_agency FROM ROSIE_DMA_EstateAgent_Mapping WHERE EstateAgent = @estateagent AND OfficeID = @office_id

IF @LocalAgencyID IS NULL AND ISNULL(RTRIM(@estateagent), '') <> '' AND ISNULL(@rid_local_agency, 0) <> 0 BEGIN

    INSERT INTO ROSIE_DMA_EstateAgent_Mapping
    (OfficeID, EstateAgent, rid_local_agency)
    VALUES 
    (@office_id, @estateagent, @rid_local_agency)

    SET @LocalAgencyID = SCOPE_IDENTITY()

END ELSE IF @DMArid_local_agency IS NULL AND ISNULL(@rid_local_agency, 0) <> 0 BEGIN

    UPDATE ROSIE_DMA_EstateAgent_Mapping
    SET rid_local_agency = @rid_local_agency
    WHERE ID = @LocalAgencyID

END

SET @status = 
    CASE
	   WHEN @system_record_state = 'archived' THEN 'E'
	   WHEN @system_record_state = 'active' AND @status = 'DO NOT CALL' THEN 'U'
	   WHEN @system_record_state = 'active' AND @status = 'Door Number Required' THEN 'R'
	   WHEN @system_record_state = 'active' AND @status <> 'DO NOT CALL' AND ISNULL(RTRIM(@houseno), '') = '' AND ISNULL(RTRIM(@housename), '') = '' THEN 'R'
	   ELSE 'A'
    END

DECLARE @BrandRef VARCHAR(5) = (SELECT org_id FROM tbl_off WHERE office_id = @office_id)

SET @rec_type = 
    CASE
	   WHEN @status = 'Contact Details Required' AND @BrandRef IN ('FIN', 'CWR') THEN 3
	   WHEN @status = 'In Contact' AND @BrandRef IN ('FIN', 'CWR') THEN 3
	   WHEN @status = 'In Wash' AND @BrandRef IN ('FIN', 'CWR') THEN 3
	   WHEN @status = 'New Lead' AND @BrandRef IN ('FIN', 'CWR') THEN 3
	   ELSE 1
    END

IF EXISTS (SELECT DMA_ID FROM DMA_Recipients WHERE DMA_ID = @dma_id)
    BEGIN
	   /* UPDATE */

	   BEGIN TRANSACTION

		  SELECT @rec_type = CASE WHEN rec_type = 14 THEN 14 ELSE @rec_type END FROM DMA_Recipients WHERE DMA_ID = @dma_id
			
		  SET @BranchAddedPhone = CASE WHEN (
			 SELECT 1 FROM DMA_Recipients 
			 WHERE DMA_ID = @dma_id
				AND ISNULL(PhoneNo, '') = '' AND ISNULL(Phone2, '') = '' AND ISNULL(Phone3, '') = ''
				AND 
				(
				    ISNULL(@phone1, '') <> ''
				    OR ISNULL(@phone2, '') <> ''
				    OR ISNULL(@phone3, '') <> ''
				    OR ISNULL(@phone4, '') <> ''
				    OR ISNULL(@phone5, '') <> ''
				    OR ISNULL(@phone6, '') <> ''
				    OR ISNULL(@phone7, '') <> ''
				    OR ISNULL(@phone8, '') <> ''
				)
			 ) = 1 THEN 1 ELSE 0 END

		  SET @BranchAddedHouseNoName = CASE WHEN (
			 SELECT 1 FROM DMA_Recipients 
			 WHERE DMA_ID = @dma_id
				AND ISNULL(houseno, '') = '' AND ISNULL(housename, '') = ''
				AND 
				(
				    ISNULL(@houseno, '') <> ''
				    OR ISNULL(@housename, '') <> ''
				)
			 ) = 1 THEN 1 ELSE 0 END
		  
		  SELECT @error = @@error
					
		  IF @error = 0
		  BEGIN
			 UPDATE DMA_Recipients				
			 SET	office_id = @office_id,
				title = @title,
				forename = @forename,
				surname = @surname,
				houseno = @houseno,
				housename = @housename, 
				addr_1 = @addr_1, 
				addr_2 = @addr_2, 
				town = @town, 
				county = @county, 
				postcode = @postcode, 
				phoneno = @DMA_PhoneNo, 
				phone2 = ISNULL(@DMA_Phone2, phone2),
				phone3 = ISNULL(@DMA_Phone3, phone3),
				estateagent = @estateagent, 
				type = @type, 
				housevalue = @housevalue, 
				status = @status,
				emailaddr = @DMA_EmailAddr, 
				rec_type = @rec_type,
				buzzbranch = @buzzbranch,
				pass2buzz = @pass2buzz,
				neg_no	= @neg_no,
				ProcessedDate = CASE @status
							 WHEN 'A' THEN GETDATE()
							 ELSE ProcessedDate
							 END,
				landlordreferral = @landlordreferral,
				houseno1 = @houseno1,  
				housename1 = @housename1,  
				addr_11 = @addr_11,
				addr_21 = @addr_21,
				town1 = @town1,
				county1 = @county1,
				postcode1 = @postcode1,
				phoneno1 = @phoneno1,
				emailaddr1 = @emailaddr1,
				title1 = @title1,
				forename1 = @forename1,
				surname1 = @surname1,
				neg_no_1 = ISNULL(@neg_no_1, neg_no_1),
				securedtxt = ISNULL(@securedtxt, securedtxt),
				board = ISNULL(@board, board),
				propURL = ISNULL(@propURL, propURL),
				POMDATE = ISNULL(@POMDATE, POMDATE),
				update_d = ISNULL(@update_d, update_d),
				update_u = ISNULL(@update_u, update_u),
				urn = @urn,
				vacant = @vacant,
				UMR = @UMR,
				Tenanted = @tenanted,
				rid_marketlead = @rid_marketlead,
				etag_marketlead = @etag_marketlead,
				DMA_EstateAgent_Rosie_Mapping_ID = @LocalAgencyID,
				BranchAddedPhone = CASE WHEN @BranchAddedPhone = 1 THEN GETDATE() ELSE BranchAddedPhone END,
				BranchAddedHouseNoName = CASE WHEN @BranchAddedHouseNoName = 1 THEN GETDATE() ELSE BranchAddedPhone END
			 WHERE DMA_ID = @dma_id					
			 
			 SELECT @error = @@ERROR
		  END

	   IF @error = 0
	   BEGIN
		  COMMIT TRANSACTION
		  SELECT @write_result = 'U'
	   END
	   ELSE
	   BEGIN
		  ROLLBACK TRANSACTION
		  SELECT @write_result = 'F'
	   END
    END
ELSE
    BEGIN
	   /* INSERT */

	   SELECT @dma_status = @status

	   SELECT @import_status = 'N'

	   IF 
	   (
		  (
			 LEN(@DMA_PhoneNo) > 10
			 AND LEFT(@DMA_PhoneNo, 1) = '0'
		  ) 
		  OR 
		  (
			 LEN(@DMA_Phone2) > 10 
			 AND LEFT(@DMA_Phone2, 1) = '0'
		  )
		  OR
		  (
			 LEN(@DMA_Phone3) > 10
			 AND LEFT(@DMA_Phone3, 1) = '0')
		  )
		  SELECT @phoneins = 1
	   ELSE
		  SELECT @phoneins = 0

	   SET @BranchAddedPhone = @phoneins

	   SET @BranchAddedHouseNoName = CASE WHEN (
			 SELECT 1 WHERE 
				ISNULL(@houseno, '') <> ''
				OR ISNULL(@housename, '') <> ''
		  ) = 1 THEN 1 ELSE 0 END

	   BEGIN TRANSACTION

		  SELECT @error = @@ERROR
			
		  IF @error = 0
		  BEGIN
			 INSERT INTO dma_recipients					
			 (					
				office_id,
				title,
				forename,
				surname,
				buzz_title,
				buzz_forename,
				buzz_surname,
				houseno,
				housename,
				addr_1,
				addr_2,
				town,
				county,
				postcode,
				phoneno,
				phone2,
				phone3,
				estateagent,
				type,
				housevalue,
				status,
				emailaddr,
				rec_type,
				buzzbranch,
				pass2buzz,
				sourcefile,
				CreatedDate,
				PhoneNoAtload,
				buzzbranchatload,
				neg_no,
				landlordreferral,
				houseno1,  
				housename1,  
				addr_11,
				addr_21,
				town1,
				county1,
				postcode1,
				phoneno1,
				emailaddr1,
				title1,
				forename1,
				surname1,
				neg_no_1,
				securedtxt,
				board,
				propURL,
				POMDATE,
				create_u,
				update_d,
				update_u,
				urn,
				vacant,
				UMR,
				Tenanted,
				rid_marketlead,
				etag_marketlead,
				DMA_EstateAgent_Rosie_Mapping_ID,
				BranchAddedPhone,
				BranchAddedHouseNoName
			 )
			 VALUES	
			 (
				@office_id,
				@title,
				@forename,
				@surname,
				@title,
				@forename,
				@surname,
				@houseno,
				@housename,
				@addr_1,
				@addr_2,
				@town,
				@county,
				@postcode,
				@DMA_PhoneNo,
				@DMA_Phone2,
				@DMA_Phone3,
				@estateagent,
				@type,
				@housevalue,
				@dma_status,
				@DMA_EmailAddr,
				@rec_type,
				@buzzbranch,
				@pass2buzz,
				@SourceFile,
				GETDATE(),
				@phoneins,
				@buzzbranch,
				@neg_no,
				@landlordreferral,
				@houseno1,  
				@housename1,  
				@addr_11,
				@addr_21,
				@town1,
				@county1,
				@postcode1,
				@phoneno1,
				@emailaddr1,
				@title1,
				@forename1,
				@surname1,
				@neg_no_1,
				@securedtxt,
				@board,
				@propURL,
				@POMDATE,
				@create_u,
				@update_d,
				@update_u,
				@urn,
				@vacant,
				@UMR,
				@tenanted,
				@rid_marketlead,
				@etag_marketlead,
				@LocalAgencyID,
				CASE WHEN @BranchAddedPhone = 1 THEN GETDATE() ELSE NULL END,
				CASE WHEN @BranchAddedHouseNoName = 1 THEN GETDATE() ELSE NULL END
			 )
			 SELECT @error = @@ERROR
			 SET @dma_id = @@IDENTITY
		  END

		  IF @error = 0
		  BEGIN				
			 INSERT INTO dbo.DMA_RecipientsImportHistory
			 (
				SourceFileName,
				SourceFileNumber,
				DMA_ID,
				HouseNo,
				HouseName,
				Addr_1,
				Addr_2,
				Town,
				County,
				Postcode,
				PhoneNo,
				EstateAgent,
				Type,
				HouseValue,
				ImportStatus,
				CreatedDate
			 )
			 VALUES
			 (
				@SourceFile,
				1,
				@dma_id,
				@houseno,
				@housename,
				@addr_1,
				@addr_2,
				@town,
				@county,
				@postcode,
				@DMA_PhoneNo,
				@estateagent,
				@type,
				@housevalue,
				@import_status,
				GETDATE()					
			 )
			 SELECT @error = @@ERROR
		  END

	   IF @error = 0
	   BEGIN
		  COMMIT TRANSACTION
		  SELECT @write_result = 'I'
	   END
	   ELSE
	   BEGIN
		  ROLLBACK TRANSACTION
		  SELECT @write_result = 'F'
	   END

	END

SELECT @dma_id AS DMA_ID, @write_result AS RESULT

--RETURN 0

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_IDBSV4_WriteDMARecipient]
    TO IDBSUser;  

GO

CREATE PROCEDURE [dbo].[ROSIE_SelOffers]
	@Office_ID VARCHAR(4)
AS
BEGIN

SELECT *
FROM
(
    SELECT
	   -- OFFER

	   -- listing_id +
	   ISNULL(p.rid_listing, -1) AS ListingId,
	   -- _related.listing_contract_purchtenants.purchtenant.id / purchtennants +
	   ISNULL(cm.rid_contact, -1) AS ListingContractPurchtenantsId,
	   -- system_modified_user_id +
	   ISNULL(updateUser.rid_accountuser, -1) AS SystemModifiedUserId,
	   -- system_owner_user_id / system_created_user_id .id +
	   ISNULL(createUser.rid_accountuser, -1) AS SystemCreatedUserId,
	   -- purchtenant_solicitor_id +
	   ISNULL(l.rid_contact, -1) AS PurchtenantSolicitorId,
	   -- agent_id +
	   ISNULL(agentUser.rid_accountuser, -1) AS AgentId,										   -- Employee Id who is managing the offer record - VARCHAR(10)
	   -- detail_sale_price_or_lease_pa +
	   ISNULL(o.off_price, -1) AS DetailSalePriceOrLeasePa,									   -- Offered price - INT   
	   -- date_actual_offer / time_actual_offer +
	   ISNULL(o.offer_d, o.create_d) AS DatetimeActualOffer,									   -- Date the offer was made - DATETIME
	   --purchtenant_position_id +
	   CASE a.status
		  WHEN 0 THEN 26594
		  WHEN 1 THEN 26621
		  WHEN 5 THEN 26591
		  WHEN 6 THEN 26592
		  WHEN 8 THEN 26620
		  WHEN 11 THEN 26593
		  WHEN 16 THEN 26624
		  WHEN 17 THEN 26623
		  WHEN 18 THEN 26618
		  WHEN 19 THEN 26619
		  WHEN 20 THEN 26595
		  ELSE -1
	   END AS PurchasePositionId,
	   -- purchtenant_legal_name +
	   ISNULL(RTRIM(CASE WHEN ISNULL(RTRIM(a.title_1), '') = '' THEN '' ELSE RTRIM(a.title_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.first_1), '') = '' THEN '' ELSE RTRIM(a.first_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.surn_1), '') = '' THEN '' ELSE RTRIM(a.surn_1) + ' ' END), '') AS PurchtenantLegalName,
	   --purchtenant_residence +
	   ISNULL(CASE WHEN ISNULL(RTRIM(a.addr1_1), '') = '' THEN '' ELSE RTRIM(a.addr1_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.addr2_1), '') = '' THEN '' ELSE RTRIM(a.addr2_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.town_1), '') = '' THEN '' ELSE RTRIM(a.town_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.county_1), '') = '' THEN '' ELSE RTRIM(a.county_1) + ' ' END +
	   CASE WHEN ISNULL(RTRIM(a.postcode_1), '') = '' THEN '' ELSE RTRIM(a.postcode_1) END, '') AS PurchtenantResidence,
	   -- notes
	   ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((
		  SELECT LEFT(Notes, LEN(Notes) - 2) AS Notes 
		  FROM
		  (
			 SELECT 
			 (
				SELECT event_data + ', ' AS [text()]
				FROM tbl_track
				WHERE track_ref = a.app_ref
				    AND event_id IN (SELECT mapped_id FROM tbl_notetypes WHERE notetype = 'offers')
				ORDER BY event_id
				FOR XML PATH ('')
			 ) AS Notes
		  ) ndata
	   ), CHAR(13), ' '), CHAR(10), ' '), '\r', ' '), '\n', ' '), '\t', ' '), '\', ''), '''', ''), '"', ''), '') AS Notes,
	   -- detail_deposit_full_or_prepayment +
	   ISNULL(a.DepositAmount, -1) AS DetailDepositFullOrPrepayment,
	   -- _related.listing_contract_conditions.condition_notes +
	   ISNULL(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(o.subject, CHAR(13), ' '), CHAR(10), ' '), '\r', ' '), '\n', ' '), '\t', ' '), '\', ''), '''', ''), '"', '')), '') AS ConditionNotes,										   -- Special Conditions - VARCHAR(254)
	   -- disclosable_interest_exists +
	   -1 AS DisclosableInterestExists,								   -- Declaration of Interest - Is there a disclosable interest regarding the applicant? - 0 = No, 1 = Yes - BIT
	   -- date_actual_accepted +
	   ISNULL(CASE o.accepted															   -- 0 = Unconfirmed, 1 = Accepted, 2 = Declined, 3 = Withdrawn - INT
		  WHEN 1 THEN COALESCE(o.response_date, o.LetterProducedDate, o.update_d)
		  ELSE NULL
	   END, '') AS DateActualAccepted,
	   -- is_backup_offer - If offer is not the latest accepted offer, mark it as backup
	   CASE WHEN o.accepted = 1 AND o.response_date <> (SELECT MAX([io].response_date) FROM tbl_offer [io] WHERE [io].prop_ref = o.prop_ref AND [io].accepted = 1) THEN 1 ELSE -1 END AS IsBackupOffer,
	   -- date_expec_unconditional
	   ISNULL(CASE WHEN o.accepted = 1 THEN ProposedExchangeDate ELSE NULL END, '1900-01-01') AS ExpectedExchangeDate,
	   -- date_expec_settlement
	   -- CASE WHEN o.accepted = 1 THEN '''''''''''''''''' ELSE NULL END AS ExpectedCompletionDate

	   -- SUBSTANTIATION

	   -- substantiated_by_user / system_owner_user / system_modified_user / system_created_user +
	   ISNULL(subsUser.rid_accountuser, -1) AS SubstantiationUserId,
	   -- position_id
	   CASE a.PurchasingPositionID
		  WHEN 1 THEN 26576
		  WHEN 3 THEN 26579
		  WHEN 4 THEN 26581
		  WHEN 6 THEN 26578
		  WHEN 7 THEN 26580
	   ELSE -1 END AS PositionId,
	   -- IF SubstantiatedDate IS NULL DONT CREATE SUBSTANTIATION RECORD
	   -- date_of
	   ISNULL(CAST(o.substantiated_date AS DATE), '1900-10-01') AS SubstantiatedDate,				   -- Date the offer was substantiated - DATETIME
	   -- _related.substantiation_contacts._id
	   ISNULL(cm.rid_contact, -1) AS SubstantiationContactsID,
	   -- note
	   ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(CASE o.evidence3														   -- Evidence of deposit received? - 0 = No, 1 = Yes - BIT
		  WHEN 1 THEN 'Evidence provided for deposit. '
		  ELSE ''
	   END +
	   CASE o.evidence2																	   -- Evidence of AIP received? - 0 = No, 1 = Yes - BIT
		  WHEN 1 THEN 'Evidence provided for AIP. '
		  ELSE ''
	   END +
	   CASE 
		  WHEN ISNULL(RTRIM(o.callnotes), '') <> '' THEN 'Notes: ' + RTRIM(o.callnotes) + ' '
		  ELSE ''
	   END + 
	   CASE 
		  WHEN ISNULL(RTRIM(o.notes), '') <> '' THEN 'Outcome notes: ' + RTRIM(o.notes) + ' '
		  ELSE ''
	   END), CHAR(13), ' '), CHAR(10), ' '), '\r', ' '), '\n', ' '), '\t', ' '), '\', ''), '''', ''), '"', ''), '') AS SubstantiationNotes,													   -- Substantiation Outcome Notes - VARCHAR(2000)
	   -- amount
	   ISNULL(o.SUBedPrice, -1) AS Amount,													   -- Value that the contact has been substantiated to - NUMERIC(10,2)
	   -- method_id
	   CASE o.face2face																	   -- Was the substantiation outcome delivered Face-to-Face? - 0 = No, 1 = Yes - BIT
		  WHEN 1 THEN 26575
		  WHEN 0 THEN 26574
		  ELSE -1
	   END AS MethodId,
	   -- status_id
	   CASE o.SubOutcome																   -- Substantiation Outcome - 1 = Proceedable, 2 = Plausible, 3 = Non-Proceedable 
		  WHEN 1 THEN 'successful'
		  WHEN 2 THEN 'in_progress'
		  WHEN 3 THEN 'failed'
		  ELSE ''
	   END AS StatusId,
	   ISNULL(DATEADD(MONTH, 3, o.substantiated_date), '1900-01-01') AS SubstantiationExpiry,

	   RTRIM(o.offer_id) AS offer_id,
	   RTRIM(o.prop_ref) AS prop_ref,
	   RTRIM(o.app_ref) AS app_ref,

	   -- Custom Fields (Declaration of Interest)
	   CASE ISNULL(CAST(o.DOI1 AS INT), -1) WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE '' END AS AppDisclosableInterestExists,		  -- Declaration of Interest - Is there a disclosable interest regarding the applicant? - 0 = No, 1 = Yes - BIT
	   CASE ISNULL(CAST(o.DOI2 AS INT), -1) WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE '' END AS SellerBeenInformed,				  -- Declaration of Interest - Has the seller been informed? - 0 = No, 1 = Yes - BIT
	   CASE ISNULL(CAST(o.DOI4 AS INT), -1) WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE '' END AS ReferToSeniorManager,			  -- Declaration of Interest - Refer to Senior Manager? - 0 = No, 1 = Yes - BIT
	   CASE ISNULL(CAST(o.DOI5 AS INT), -1) WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE '' END AS SellerDisclosableInterestExists,	  -- Is there a disclosable interest regarding the seller? - 0 = No, 1 = Yes - BIT
	   CASE ISNULL(CAST(o.DOI6 AS INT), -1) WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE '' END AS AppBeenInformed,				  -- Has the applicant been informed? - 0 = No, 1 = Yes - BIT 
	   CASE o.qualified 
		  WHEN 1 THEN 'Proceedable'
		  ELSE 
		  CASE o.SubOutcome																					  -- Substantiation Outcome - 1 = Proceedable, 2 = Plausible, 3 = Non-Proceedable 
			 WHEN 1 THEN 'Proceedable'
			 WHEN 2 THEN 'Plausible'
			 WHEN 3 THEN 'Not Proceedable'
			 ELSE 'Not Substantiated Yet'
		  END 
	   END AS OutcomeForEA,
	   
	   ROW_NUMBER() OVER(PARTITION BY o.prop_ref, o.app_ref ORDER BY o.offer_d DESC, CASE WHEN o.accepted = 1 THEN 0 ELSE 1 END) AS OfferNumber
	   
    FROM tbl_offer o
    JOIN tbl_prop p
	   ON o.prop_ref = p.prop_ref
    JOIN tbl_apps a
	   ON o.app_ref = a.app_ref
    JOIN tbl_Customer c
	   ON a.customer_ref = c.client_ref
    JOIN RosieCustomerMigration cm
	   ON c.id = cm.CustomerID
    LEFT JOIN tbl_legal l
	   ON l.legal_id = a.legal_cd
    LEFT JOIN tbl_staff createUser
	   ON createUser.emp_id = o.create_u								    -- Employee Id who created the offer record - VARCHAR(10)
    LEFT JOIN tbl_staff updateUser
	   ON updateUser.emp_id = o.update_u								    -- Employee Id who last updated the offer - VARCHAR(10)
    LEFT JOIN tbl_staff agentUser
	   ON agentUser.emp_id = o.neg_no
    LEFT JOIN tbl_staff AS subsUser
	   ON subsUser.emp_id = o.Substantiated_by							    -- Employee Id who substantiated the offer - VARCHAR(10)
	   AND subsUser.rid_accountuser IS NOT NULL
    WHERE
	   cm.rid_contact IS NOT NULL 
	   AND p.rid_listing IS NOT NULL
	   AND p.office_id = @Office_ID
	   --AND p.rid_listing IN (204, 130)
) data
WHERE OfferNumber = 1

END

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_SelOffers]
    TO IDBSUser;  

GO

CREATE PROCEDURE [dbo].[ROSIE_IDBSV4_WriteOffer] 
    @rid_listing INT,
    @Sub_rid_accountuser INT,
    @Off_rid_accountuser INT,
    @rid_contact INT,
    
    @off_price INT = NULL, -- DetailSalePriceOrLeasePa
    @subject VARCHAR(254) = NULL, -- ConditionNotes
    @create_d_uts INT = NULL,
    @update_d_uts INT = NULL,
    @offer_date DATE = NULL, -- date_actual_offer
    @offer_time TIME = NULL, -- time_actual_offer
    @response_d DATE = NULL, -- date_actual_communicated
    @response_t TIME = NULL, -- date_actual_communicated
    @accepted_date DATETIME,

    -- Offer History
    @num_offers INT, -- count offer history

    -- Substantiation
    @substantiated_date DATETIME = NULL,
    @notes VARCHAR(2000) = NULL, -- SubstantiationNotes
    @callnotes VARCHAR(250) = NULL, -- SubstantiationNotes
    @sub_status_id VARCHAR(100),
    @sub_method_id INT,
    @sub_system_modtime BIGINT,
    @SUBedPrice NUMERIC(10,2) = NULL, -- Amount
    
    -- DOI Custom Fields
    @AppDisclosableInterestExists VARCHAR(100),
    @SellerBeenInformed VARCHAR(100),
    @ReferToSeniorManager VARCHAR(100),
    @SellerDisclosableInterestExists VARCHAR(100),
    @AppBeenInformed VARCHAR(100),
    @OutcomeForEA VARCHAR(100),

    @rid_contract INT,
    @etag_contract VARCHAR(72)

    --@returned_prop_ref NVARCHAR(25) OUTPUT,
    --@write_result NVARCHAR(1) OUTPUT,
    --@new_update_d DATETIME OUTPUT
AS

    DECLARE @offer_user VARCHAR(10) = (SELECT emp_id FROM tbl_staff WHERE rid_accountuser = @Off_rid_accountuser),
	   @sub_user VARCHAR(10) = (SELECT emp_id FROM tbl_staff WHERE rid_accountuser = @Sub_rid_accountuser),
	   @app_surname VARCHAR(50),
	   @prop_address VARCHAR(100),
	   @existingoffercount INT = 0,
	   @existingaccepted INT = 0,
	   @offcounteventid INT = 
		  CASE WHEN @num_offers = 1 THEN 100
			 WHEN @num_offers = 2 THEN 101
			 WHEN @num_offers = 3 THEN 102
			 WHEN @num_offers = 4 THEN 103
			 WHEN @num_offers = 5 THEN 104
			 WHEN @num_offers = 6 THEN 105
			 ELSE 105 END,
	   @offcount VARCHAR(5) = 
		  CASE WHEN @num_offers = 1 THEN '1st'
			 WHEN @num_offers = 2 THEN '2nd'
			 WHEN @num_offers = 3 THEN '3rd'
			 WHEN @num_offers = 4 THEN '4th'
			 WHEN @num_offers = 5 THEN '5th'
			 WHEN @num_offers = 6 THEN '6th +'
			 ELSE '6th +' END

    DECLARE @prop_ref NVARCHAR(25), @office_id VARCHAR(4)

    SELECT @prop_ref = prop_ref, @office_id = office_id FROM tbl_prop WHERE rid_listing = @rid_listing

    DECLARE @app_ref VARCHAR(25) = (
		  SELECT TOP 1 a.app_ref 
		  FROM tbl_apps a 
		  INNER JOIN tbl_Customer c 
			 ON a.customer_ref = c.client_ref
		  INNER JOIN RosieCustomerMigration r
			 ON c.id = r.CustomerID
			 AND r.rid_contact = @rid_contact
		  ORDER BY CASE WHEN office_id = @office_id THEN 0 ELSE 1 END
	   )

    DECLARE @create_u VARCHAR(10) = @offer_user,
	   @update_u VARCHAR(10) = @offer_user,
	   @neg_no VARCHAR(10) = @offer_user,
	   @Substantiated_by VARCHAR(10) = @sub_user,
	   @f2fempid VARCHAR(10) = @sub_user,
	   @qualified INT = CASE @OutcomeForEA WHEN 'Proceedable' THEN 1 WHEN 'Not Proceedable' THEN 2 ELSE NULL END,
	   @accepted INT = CASE WHEN @accepted_date IS NULL THEN 0 ELSE 1 END,
	   @CustomerRefused BIT = CASE @sub_status_id WHEN 'refused' THEN 1 ELSE NULL END,
	   @SubOutcome INT = CASE @OutcomeForEA WHEN 'Proceedable' THEN 1 WHEN 'Plausible' THEN 2 WHEN 'Not Proceedable' THEN 3 ELSE NULL END,
	   @face2face BIT = CASE @sub_method_id WHEN 26575 THEN 1 WHEN 26574 THEN 0 ELSE NULL END,
	   @f2fdate DATETIME = CASE @sub_method_id WHEN 26575 THEN DATEADD(SECOND, @sub_system_modtime , '19700101') ELSE NULL END,
	   @create_d DATETIME = DATEADD(SECOND, @create_d_uts, '19700101'),
	   @update_d DATETIME = DATEADD(SECOND, @update_d_uts, '19700101'),
	   @offer_d DATETIME = CAST(@offer_date AS DATETIME) + CAST(@offer_time AS DATETIME),
	   @response_date DATETIME = CAST(@response_d AS DATETIME) + CAST(@response_t AS DATETIME),
	   @DOI1 BIT = CASE @AppDisclosableInterestExists WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END,
	   @DOI2 BIT = CASE @SellerBeenInformed WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END,
	   @DOI4 BIT = CASE @ReferToSeniorManager WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END,
	   @DOI5 BIT = CASE @SellerDisclosableInterestExists WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END,
	   @DOI6 BIT = CASE @AppBeenInformed WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 ELSE NULL END,

	   @upd_flag INT = NULL,
	   @chain_position INT = NULL,
	   @able2proceed BIT = NULL,
	   @source INT = NULL,
	   @s_other VARCHAR(50) = NULL,

	   @Evidence1 BIT = NULL,
	   @evidence2 BIT = NULL,
	   @evidence3 BIT = NULL,
	   @Sent2JustMortgages BIT = NULL,
	   @sent2JM DATETIME = NULL,
	   @sent2BM DATETIME = NULL,
	   @LetterRequestdate DATETIME = NULL,
	   @LetterRequestEmp_ID VARCHAR(10) = NULL,
	   @LetterProducedDate DATETIME = NULL,
	   @LetterProducedEmp_ID VARCHAR(10) = NULL,
	   @appexpectingcall BIT = NULL,
	   @SecondaryPurchase BIT = NULL,
	   @WithdrawReason VARCHAR(250) = NULL

    DECLARE @offer_id VARCHAR(10) = (SELECT TOP 1 offer_id FROM tbl_offer WHERE prop_ref = @prop_ref AND app_ref = @app_ref ORDER BY offer_d DESC, CASE WHEN accepted = 1 THEN 0 ELSE 1 END)

    /* Trim Input Parameters */
    
    SET @prop_ref = RTRIM(LTRIM(@prop_ref));
    SET @offer_id = RTRIM(LTRIM(@offer_id));
    SET @app_ref = RTRIM(LTRIM(@app_ref));
    SET @subject = RTRIM(LTRIM(@subject));
    SET @Substantiated_by = RTRIM(LTRIM(@Substantiated_by));
    SET @create_u = RTRIM(LTRIM(@create_u));
    SET @neg_no = RTRIM(LTRIM(@neg_no));
    SET @update_u = RTRIM(LTRIM(@update_u));
    SET @notes = RTRIM(LTRIM(@notes));
    SET @LetterRequestEmp_ID = RTRIM(LTRIM(@LetterRequestEmp_ID));
    SET @LetterProducedEmp_ID = RTRIM(LTRIM(@LetterProducedEmp_ID));
    SET @WithdrawReason = RTRIM(LTRIM(@WithdrawReason));
    SET @callnotes = RTRIM(LTRIM(@callnotes));
    SET @f2fempid = RTRIM(LTRIM(@f2fempid));

    IF EXISTS (
	   SELECT NULL
	   FROM tbl_offer
	   WHERE prop_ref = @prop_ref
		  AND offer_id = @offer_id
    )
    BEGIN

	   SELECT @existingoffercount = CASE WHEN MAX(num_offers) IS NULL THEN COUNT(*) ELSE MAX(num_offers) END
	   FROM tbl_offer
	   WHERE prop_ref = @prop_ref
		  AND offer_id = @offer_id
	   ORDER BY CASE WHEN MAX(num_offers) IS NULL THEN 2 ELSE 1 END

    END

    DECLARE @error INT;

    --SELECT @new_update_d = GETDATE();
    --SELECT @returned_prop_ref = @prop_ref;

    IF EXISTS
    (
	   SELECT @offer_id
	   FROM dbo.tbl_offer WITH(NOLOCK)
	   WHERE offer_id = @offer_id
    )
    BEGIN
	   BEGIN TRANSACTION;
             
	   SELECT @error = @@error;

	   UPDATE tbl_offer
	   SET prop_ref  = @prop_ref,
            offer_id = @offer_id,
            app_ref = @app_ref,
            off_price = @off_price,
            subject = @subject,
            qualified = @qualified,
            accepted = @accepted,
            --create_d = @create_d,
            update_d = @update_d,
            --upd_flag = @upd_flag,
            --chain_position = @chain_position,
            substantiated_date = CASE WHEN @substantiated_date = '1900-10-01 00:00:00' THEN NULL ELSE @substantiated_date END,
            DOI1 = @DOI1,
            DOI2 = @DOI2,
            DOI4 = @DOI4,
            DOI5 = @DOI5,
            DOI6 = @DOI6,
            Substantiated_by = @Substantiated_by,
            --Sent2JustMortgages = @Sent2JustMortgages,
            --Evidence1 = @Evidence1,
            --evidence2 = @evidence2,
            --evidence3 = @evidence3,
            --create_u = @create_u,
            neg_no = @neg_no,
            offer_d = @offer_d,
            response_date = ISNULL(@response_date, response_date),
            update_u = @update_u,
            SUBedPrice = @SUBedPrice,
            --sent2JM = @sent2JM,
            --sent2BM = @sent2BM,
            --able2proceed = @able2proceed,
            notes = @notes,
            --LetterRequestdate = @LetterRequestdate,
            --LetterRequestEmp_ID = @LetterRequestEmp_ID,
            --LetterProducedDate = @LetterProducedDate,
            --LetterProducedEmp_ID = @LetterProducedEmp_ID,
            --SecondaryPurchase = @SecondaryPurchase,
            --appexpectingcall = @appexpectingcall,
            --WithdrawReason = @WithdrawReason,
            CustomerRefused = @CustomerRefused,
            callnotes = @callnotes,
            SubOutcome = @SubOutcome,
            face2face = @face2face,
            f2fempid = @f2fempid,
            f2fdate = @f2fdate,
		  num_offers = @num_offers,
		  rid_contract = @rid_contract,
		  etag_contract = @etag_contract
	   WHERE offer_id = @offer_id
	   
	   IF @error = 0
        BEGIN
            COMMIT TRANSACTION;
            --SELECT @write_result = 'U';
        END;
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            --SELECT @write_result = 'F';
            --SELECT @new_update_d = NULL;
        END;
    END;
    ELSE
    BEGIN
	   BEGIN TRANSACTION;

	   SELECT @error = @@error;

	   SET @offer_id = '_' + RIGHT(NEWID(), 9)

	   INSERT INTO tbl_offer
	   (
		  prop_ref,
		  offer_id,
		  app_ref,
		  off_price,
		  source,
		  s_other,
		  subject,
		  qualified,
		  accepted,
		  create_d,
		  update_d,
		  upd_flag,
		  chain_position,
		  substantiated_date,
		  DOI1,
		  DOI2,
		  DOI3,
		  DOI4,
		  Substantiated_by,
		  Sent2JustMortgages,
		  Evidence1,
		  evidence2,
		  evidence3,
		  create_u,
		  neg_no,
		  offer_d,
		  response_date,
		  update_u,
		  SUBedPrice,
		  sent2JM,
		  sent2BM,
		  able2proceed,
		  notes,
		  LetterRequestdate,
		  LetterRequestEmp_ID,
		  LetterProducedDate,
		  LetterProducedEmp_ID,
		  SecondaryPurchase,
		  appexpectingcall,
		  DOI5,
		  DOI6,
		  WithdrawReason,
		  CustomerRefused,
		  callnotes,
		  SubOutcome,
		  face2face,
		  f2fempid,
		  f2fdate,
		  num_offers,
		  rid_contract,
		  etag_contract
	   )
	   VALUES
	   (
		  @prop_ref, 
		  @offer_id,
		  @app_ref,
		  @off_price,
		  @source,
		  @s_other,
		  @subject,
		  @qualified,
		  @accepted,
		  @create_d,
		  @update_d,
		  @upd_flag,
		  @chain_position,
		  @substantiated_date,
		  @DOI1,
		  @DOI2,
		  NULL,
		  @DOI4,
		  @Substantiated_by,
		  @Sent2JustMortgages,
		  @Evidence1,
		  @evidence2,
		  @evidence3,
		  @create_u,
		  @neg_no,
		  @offer_d,
		  @response_date,
		  @update_u,
		  @SUBedPrice,
		  @sent2JM,
		  @sent2BM,
		  @able2proceed,
		  @notes,
		  @LetterRequestdate,
		  @LetterRequestEmp_ID,
		  @LetterProducedDate,
		  @LetterProducedEmp_ID,
		  @SecondaryPurchase,
		  @appexpectingcall,
		  @DOI5,
		  @DOI6,
		  @WithdrawReason,
		  @CustomerRefused,
		  @callnotes,
		  @SubOutcome,
		  @face2face,
		  @f2fempid,
		  @f2fdate,
		  @num_offers,
		  @rid_contract,
		  @etag_contract
	   )

	   IF @error = 0
	   BEGIN
		  COMMIT TRANSACTION;
		  --SELECT @write_result = 'U';
	   END;
	   ELSE
	   BEGIN
		  ROLLBACK TRANSACTION;
		  --SELECT @write_result = 'F';
		  --SELECT @new_update_d = NULL;
	   END;
    END

    -- Section to set up events for KPI reporting
    --
    -- K077 Offers (Count)
    -- 
    IF ISNULL(@num_offers, 0) > 0
    BEGIN
	   IF @existingoffercount < @num_offers
	   BEGIN
		  SELECT @app_surname = surn_1
		  FROM tbl_apps
		  WHERE app_ref = @app_ref

		  SELECT @prop_address = LTRIM(RTRIM(addr_1 + ', ' + post_code))
		  FROM tbl_prop
		  WHERE prop_ref = @prop_ref
			
		  -- Create the Property tracking event (based on applicant details)
		  INSERT INTO tbl_track
		  (
			 track_id, 
			 track_type, 
			 track_ref, 
			 event_date, 
			 event_id, 
			 event_data, 
			 event_val,
			 event_val2,
			 neg_no,
			 update_u
		  )
		  VALUES
		  (
			 RIGHT(NEWID(), 10), 
			 1, 
			 @prop_ref, 
			 GETDATE(), 
			 @offcounteventid, 
			 @offcount + ' Offer £' + CAST(@off_price AS VARCHAR) + ' ' + @app_ref + ' (' + @app_surname + ')', 
			 @off_price,
			 NULL,
			 @neg_no,
			 @neg_no
		  );

		  -- Create the Applicant tracking event (based on property details)
		  INSERT INTO tbl_track
            (
			 track_id, 
			 track_type, 
			 track_ref, 
			 event_date, 
			 event_id, 
			 event_data, 
			 event_val,
			 event_val2,
			 neg_no,
			 update_u
            )
            VALUES
            (
			 RIGHT(NEWID(), 10), 
			 2, 
			 @app_ref, 
			 GETDATE(), 
			 @offcounteventid, 
			 @offcount + ' Offer £' + CAST(@off_price AS VARCHAR) + ' Against ' + @prop_ref + ' ' + @prop_address, 
			 @off_price,
			 NULL,
			 @neg_no,
			 @neg_no
            );
	   END
    END

    --
    -- K411 Offers Accepted (Count)
    --
    IF @accepted = 1
    BEGIN
	   SELECT @existingaccepted = COUNT(*)
	   FROM tbl_track
	   WHERE track_ref = @prop_ref
		  AND event_id = 115

	   IF @existingaccepted = 0
	   BEGIN
		  SELECT @app_surname = surn_1
		  FROM tbl_apps
		  WHERE app_ref = @app_ref

		  INSERT INTO tbl_track
            (
			 track_id, 
			 track_type, 
			 track_ref, 
			 event_date, 
			 event_id, 
			 event_data, 
			 event_val,
			 event_val2,
			 neg_no,
			 update_u
            )
            VALUES
            (
			 RIGHT(NEWID(), 10), 
			 1, 
			 @prop_ref, 
			 GETDATE(), 
			 115, 
			 'Offer Accepted' + ' (' + @app_surname + ')', 
			 1,
			 0,
			 '',
			 @neg_no
            );
	   END
    END

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_IDBSV4_WriteOffer]
    TO IDBSUser;  

GO

CREATE PROCEDURE [dbo].[ROSIE_SelOfferHistory]
	@Office_ID VARCHAR(4),
	@rid_listing VARCHAR(100),
	@rid_contact VARCHAR(100)
AS
BEGIN

SELECT
    -- amount
    ISNULL(o.off_price, -1) AS DetailSalePriceOrLeasePa,
    -- offer_date / offer_time
    ISNULL(o.offer_d, o.create_d) AS DatetimeActualOffer,
    o.offer_id,
    o.prop_ref,
    o.app_ref

FROM tbl_offer o
JOIN tbl_prop p
    ON o.prop_ref = p.prop_ref
JOIN tbl_apps a
    ON o.app_ref = a.app_ref
JOIN tbl_Customer c
    ON a.customer_ref = c.client_ref
JOIN RosieCustomerMigration cm
    ON c.id = cm.CustomerID
WHERE 
    cm.rid_contact = CAST(@rid_contact AS INT)
    AND p.rid_listing = CAST(@rid_listing AS INT)
    AND p.office_id = @Office_ID
ORDER BY ISNULL(o.offer_d, o.create_d), o.off_price

END

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_SelOfferHistory]
    TO IDBSUser;  

GO

CREATE PROCEDURE [dbo].[ROSIE_UpdateOfferEtags]
	@OfferID VARCHAR(10),
	@PropRef VARCHAR(25),
	@AppRef VARCHAR(25),
	@rid_contract INT,
	@etag_contract NVARCHAR(72)

AS
BEGIN

UPDATE tbl_offer
SET rid_contract = @rid_contract,
    etag_contract = @etag_contract
WHERE 
    offer_id = @OfferID
    AND prop_ref = @PropRef
    AND app_ref = @AppRef

END

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_UpdateOfferEtags]
    TO IDBSUser;  

GO

CREATE PROCEDURE [dbo].[ROSIE_UpdateOfferSubstantiation]
	@OfferID VARCHAR(10),
	@PropRef VARCHAR(25),
	@AppRef VARCHAR(25),
	@rid_substantiation INT

AS
BEGIN

UPDATE tbl_offer
SET rid_substantiation = @rid_substantiation
WHERE 
    offer_id = @OfferID
    AND prop_ref = @PropRef
    AND app_ref = @AppRef

END

GO

GRANT EXECUTE ON OBJECT::[dbo].[ROSIE_UpdateOfferSubstantiation]
    TO IDBSUser;  

GO

use [Rosie]

go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RexPropertyLastRunLog](
	[LastRequestDate] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RexPropertyLog](
	RexPropId int IDENTITY(1,1) NOT NULL,
	PropRef varchar(64) NOT NULL,
	ActionPerformed varchar(16) NOT NULL,
	SyncDate datetime null default getdate(),
	Response text NOT NULL
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RexUserLog](
	RexUserId int IDENTITY(1,1) NOT NULL,
	AccountName varchar(64) NOT NULL,
	ActionPerformed varchar(16) NOT NULL,
	Data varchar(8000) NULL,
	SyncDate datetime null default getdate(),
	Response text NOT NULL
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create TABLE [dbo].[ROSIE_ContactsLastRunLog](
	LastRequestDate datetime NOT NULL,
	office_id varchar(4) not null
) ON [PRIMARY]

GO

create table CategoryValues (
	ID int IDENTITY(1,1) NOT NULL,
	ListName varchar(256) not null,
	Rex_ID int not null,
	text varchar(256) not null
 CONSTRAINT [PK_CategoryValues_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE dbo.PackageLastRun (
    PackageName VARCHAR(200),
    AccountId INT,
    LastRunTime DATETIME,
	FirstRunTime DATETIME DEFAULT GETDATE(),
    PRIMARY KEY(PackageName, AccountId)
)

GO

CREATE TABLE SSISErrorLog
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    PackageName VARCHAR(200),
    AccountID INT,
    StartTime DATETIME,
    ErrorCode INT,
    ErrorDescription VARCHAR(4000)
)

GO

CREATE TABLE SSISSuccessLog
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    PackageName VARCHAR(200),
    AccountID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    Ignored INT,
    Upserted INT,
    Failed INT
)

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspGetRexLastRunDates]
AS
BEGIN

declare @testDate datetime 
select @testDate = LastRequestDate from RexPropertyLastRunLog

declare @startDate datetime 
declare @endDate datetime 
declare @now datetime = getdate()
declare @Weeks int

--Set start date to the last requested date
set @startDate = @testDate 
set @endDate = getdate()

SELECT @Weeks = DATEDIFF(WW,@StartDate,@EndDate)

if @Weeks > 1 
	select @EndDate = DATEADD(Week, 1, @StartDate)

select @startDate as StartDate, @endDate as EndDate

END

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUpdRexLastRunDates]
	@LastRequestDate datetime
AS
BEGIN
update RexPropertyLastRunLog
set
LastRequestDate = @LastRequestDate
END

go

insert into RexLastRunLog values ('2018-Jul-01')

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspInsRexPropertyLog]
	@PropRef varchar(64),
	@ActionPerformed varchar(16),
	@Response text,
	@SyncDate datetime = null	
AS
BEGIN
if (@SyncDate is null) select @SyncDate=getdate()

Insert into RexPropertyLog (PropRef,ActionPerformed,SyncDate,Response)
values (@PropRef,@ActionPerformed,@SyncDate,@Response)
END

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspInsRexUserLog]
	@AccountName varchar(64),
	@ActionPerformed varchar(16),
	@Data varchar(8000) = null,
	@Response text,	
	@SyncDate datetime = null	
AS
BEGIN
if (@SyncDate is null) select @SyncDate=getdate()

Insert into RexUserLog (AccountName,ActionPerformed,Data,SyncDate,Response)
values (@AccountName,@ActionPerformed,@Data,@SyncDate,@Response)
END

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ROSIE_uspGetContactsLastRunDates]
	@office_id varchar(4)
AS
BEGIN

declare @testDate datetime 
select @testDate = LastRequestDate from ROSIE_ContactsLastRunLog where office_id=@office_id

declare @startDate datetime 
declare @endDate datetime 
declare @now datetime = getdate()
declare @Weeks int

--Set start date to the last requested date
set @startDate = @testDate 
set @endDate = getdate()

SELECT @Weeks = DATEDIFF(WW,@StartDate,@EndDate)

if @Weeks > 1 
	select @EndDate = DATEADD(Week, 1, @StartDate)

select @startDate as StartDate, @endDate as EndDate

END

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROSIE_uspUpdContactsLastRunDates]
	@LastRequestDate datetime,
	@office_id varchar(4)
AS
BEGIN

	declare @count int
	select @count=count(*) from ROSIE_ContactsLastRunLog where office_id=@office_id


	if @count=0
	begin
		update ROSIE_ContactsLastRunLog
		set
		LastRequestDate = @LastRequestDate
		where
		office_id=@office_id
	end
	if @count!=0
	begin
		insert into ROSIE_ContactsLastRunLog (LastRequestDate,office_id) values (@LastRequestDate,@office_id)
	end
END

go

insert into ROSIE_ContactsLastRunLog values ('2018-Jul-01','0129')
insert into ROSIE_ContactsLastRunLog values ('2018-Jul-01','0115')

go

insert into CategoryValues values ('listing_subcat_residential_sale',40400,'Barn Conversion') 
insert into CategoryValues values('listing_subcat_residential_sale',40401,'Block of Flats') 
insert into CategoryValues values('listing_subcat_residential_sale',40402,'Bungalow') 
insert into CategoryValues values('listing_subcat_residential_sale',40403,'Chalet') 
insert into CategoryValues values('listing_subcat_residential_sale',40404,'Cottage') 
insert into CategoryValues values('listing_subcat_residential_sale',40405,'Country House') 
insert into CategoryValues values('listing_subcat_residential_sale',40407,'Detached bungalow') 
insert into CategoryValues values('listing_subcat_residential_sale',40406,'Detached house') 
insert into CategoryValues values('listing_subcat_residential_sale',40408,'End of terrace house') 
insert into CategoryValues values('listing_subcat_residential_sale',40409,'Finca') 
insert into CategoryValues values('listing_subcat_residential_sale',40410,'Flat') 
insert into CategoryValues values('listing_subcat_residential_sale',40411,'House Boat') 
insert into CategoryValues values('listing_subcat_residential_sale',40412,'Link detached house') 
insert into CategoryValues values('listing_subcat_residential_sale',40413,'Lodge') 
insert into CategoryValues values('listing_subcat_residential_sale',40414,'Longere') 
insert into CategoryValues values('listing_subcat_residential_sale',40415,'Maisonette') 
insert into CategoryValues values('listing_subcat_residential_sale',40416,'Mews house') 
insert into CategoryValues values('listing_subcat_residential_sale',40417,'Park home') 
insert into CategoryValues values('listing_subcat_residential_sale',40418,'Riad') 
insert into CategoryValues values('listing_subcat_residential_sale',40420,'Semi-detached bungalow') 
insert into CategoryValues values('listing_subcat_residential_sale',40419,'Semi-detached house') 
insert into CategoryValues values('listing_subcat_residential_sale',40422,'Terraced bungalow') 
insert into CategoryValues values('listing_subcat_residential_sale',40421,'Terraced House') 
insert into CategoryValues values('listing_subcat_residential_sale',40423,'Town House') 
insert into CategoryValues values('listing_subcat_residential_sale',40424,'Villa') 

go

CREATE PROCEDURE [dbo].[uspGetCategory]
	@search VARCHAR(50),
	@list varchar(50)
AS 
BEGIN

declare @searchfor varchar(100)

if @search = 'Flat / Apartment' 
begin
	select @searchfor = 'Flat'
end
else if @search = 'Detached-House' 
begin
	select @searchfor = 'Detached House'
end
else 
begin
	select @searchfor = @search
end

select Rex_ID,text from CategoryValues where text=@searchfor and ListName=@list

end
go