/****************************************************


	POPULATE AND LINK MISSING CUSTOMERs 


*****************************************************/

--------------------------------------
-- Applicant 1
--------------------------------------

SELECT * 
INTO #tempcreatecustomers
FROM	(

		SELECT	Rectype = 'Applicant 1',
				reference = A.app_ref,
				title = RTRIM(A.title_1), 
				firstname = RTRIM(A.first_1) , 
				lastname = RTRIM(A.surn_1), 
				addr_1 = RTRIM(A.addr1_1),
				addr_2 = RTRIM(A.addr2_1),
				town = rtrim(A.town_1),
				county = rtrim(county_1),
				postcode = RTRIM(A.postcode_1),
				landline = rtrim(A.telnoh_1),
				mobile = rtrim(a.telnom_1) ,
				email = rtrim(a.email_1),
				urn = A.urn
		
		
		from	tbl_apps A with (nolock) 
		where	A.customer_ref is null 
				and A.create_d >= dateadd(year, -7, getdate())
				and a.vend_prop is null

		union all		
		--------------------------------------
		-- Applicant 2
		--------------------------------------	

		SELECT	Rectype = 'Applicant 2',
				reference = A.app_ref,
				title = RTRIM(A.title_2), 
				firstname = RTRIM(A.first_2) , 
				lastname = RTRIM(A.surn_2), 
				addr_1 = RTRIM(A.addr1_2),
				addr_2 = RTRIM(A.addr2_2),
				town = rtrim(A.town_2),
				county = rtrim(county_2),
				postcode = RTRIM(A.postcode_2),
				landline = rtrim(A.telnoh_2),
				mobile = rtrim(a.telnom_2) ,
				email = rtrim(a.email_2),
				urn = NULL
		
		from	tbl_apps A with (nolock) 
		where	A.customer_ref1 is null 
				and A.create_d >= dateadd(year, -7, getdate())
				--and rtrim(isnull(a.email_2,'')) <> ''
				and rtrim(isnull(a.surn_2,'')) <> ''
	
		union all	
		-----------------------------	
		-- vendor 1
		-----------------------------
	
		SELECT	Rectype = 'Vendor 1',
				reference = P.prop_ref,
				title = RTRIM(P.vtitle), 
				firstname = isnull(p.vinit,RTRIM(P.vfirstname) ), 
				lastname = RTRIM(P.cont_name), 
				addr_1 = RTRIM(p.vaddr_1),
				addr_2 = RTRIM(p.vaddr_2),
				town = rtrim(P.vtown),
				county = rtrim(p.vcounty),
				postcode = RTRIM(p.vpostcode),
				landline = rtrim(p.cont_telno),
				mobile = rtrim(p.cont_mobno) ,
				email = rtrim(p.vemail),
				urn = p.urn
		from	tbl_prop P with (nolock) 
		where	P.customer_ref is null 
				and P.create_d >= dateadd(year, -7, getdate())

		union all	
		-----------------------------	
		-- vendor 2
		-----------------------------
	
		SELECT	Rectype = 'Vendor 2',
				reference = P.prop_ref,
				title = RTRIM(P.vtitle), 
				firstname = isnull(p.vinit,RTRIM(P.vfirstname) ), 
				lastname = RTRIM(P.cont_name), 
				addr_1 = RTRIM(p.vaddr_1),
				addr_2 = RTRIM(p.vaddr_2),
				town = rtrim(P.vtown),
				county = rtrim(p.vcounty),
				postcode = RTRIM(p.vpostcode),
				landline = rtrim(p.cont_telno),
				mobile = rtrim(p.cont_mobno) ,
				email = rtrim(p.vemail),
				urn = null
		from	tbl_fwdaddr P with (nolock) 
				left outer join tbl_prop p1 with (nolock)
					on p.prop_Ref = p1.prop_Ref 
		where	P.customer_ref is null 
				and p1.create_d >= dateadd(year, -7, getdate())
				and rtrim(isnull(p.cont_name,'')) <> ''
				) aaa



-----------------------------
-- Create customer and link
-----------------------------

DECLARE @reference varchar(25), 
	@app_title varchar(20),
	@app_forename varchar(50), 
	@app_lastname varchar(50),
	@app_telephone_std varchar(10), 
	@app_telephone varchar(50),
	@app_mobile varchar(50) , 
	@app_email varchar(200) ,
	@URN varchar(8),
	@addr_1 varchar(100),
	@addr_2 varchar(100),
	@Town varchar(100),
	@County varchar(100),
	@Postcode varchar(10),
	@rectype varchar(20),
	@client_ref varchar(25)


DECLARE Customers CURSOR FOR  
SELECT top 100000 reference , title, firstname, lastname, left(ltrim(landline),5), substring(ltrim(landline),6,len(landline)),	
	mobile, email, URN, addr_1, addr_2,	Town, County, Postcode,rectype 
FROM #tempcreatecustomers
OPEN Customers;  
FETCH NEXT FROM Customers  INTO @reference , @app_title, @app_forename, @app_lastname, @app_telephone_std, @app_telephone,	@app_mobile, 
								@app_email, @URN, @addr_1, @addr_2,	@Town, @County, @Postcode,@rectype 
WHILE @@FETCH_STATUS = 0  
   BEGIN  

		---------------------------
		-- Create customer 
		---------------------------
		
		SELECT	@client_ref = 'C' + right('0000000000' + rtrim(ltrim(cast(max(ID) + 1 as varchar))),10) 
		FROM	tbl_customer WITH (NOLOCK)
			

		INSERT INTO tbl_customer (client_ref,app_title, app_forename, app_lastname, app_telephone_std, app_telephone,	app_mobile, 
								app_email, URN, addr_1, addr_2,	Town, County, Postcode,create_u)
		VALUES (@client_ref, isnull(@app_title,''), isnull(@app_forename,''), @app_lastname, isnull(@app_telephone_std,''), isnull(@app_telephone,''),	isnull(@app_mobile,''), 
								isnull(@app_email,''), @URN, @addr_1, @addr_2,	@Town, @County, @Postcode, 'ROSIE')

		------------------------------
		-- LINK
		------------------------------

		IF @rectype = 'Applicant 1'
			BEGIN
				UPDATE	tbl_apps 
				SET		customer_ref = @client_ref
				WHERE	app_ref = @reference

			END

		IF @rectype = 'Applicant 2'
			BEGIN
				UPDATE	tbl_apps 
				SET		customer_ref1 = @client_ref
				WHERE	app_ref = @reference

			END
	
		IF @rectype = 'Vendor 1'
			BEGIN
				UPDATE	tbl_prop 
				SET		customer_ref = @client_ref
				WHERE	prop_ref = @reference

			END

	
		IF @rectype = 'Vendor 2'
			BEGIN
				UPDATE	tbl_fwdaddr
				SET		customer_ref = @client_ref
				WHERE	prop_ref = @reference

			END

			print 'Linked: ' + @client_ref + ' ' + @reference  + ' ' + @rectype 

      FETCH NEXT FROM Customers  INTO @reference , @app_title, @app_forename, @app_lastname, @app_telephone_std, @app_telephone,	@app_mobile, 
								@app_email, @URN, @addr_1, @addr_2,	@Town, @County, @Postcode,@rectype 
   END;  
CLOSE Customers;  
DEALLOCATE Customers;  


DROP TABLE #tempcreatecustomers
