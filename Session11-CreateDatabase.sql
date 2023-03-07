use master

if exists (select * from sys.databases where Name='Session11')
drop database Session11
go


create database Session11
go
use Session11


--CREATE TABLE PRODUCT
create table Product (
    p_id int identity (1,1) primary key,
	p_name nvarchar(50) not null,
	p_desc nvarchar(100) not null,
	p_unit nvarchar(10) not null,
	p_price money
)
go


--CREATE TABLE CUSTOMER
create table Customer (
   c_id int identity(1, 1) primary key,
   c_name nvarchar(50) not null,
   c_phone varchar(20) not null,
)


--CREATE TBALE ADDRESS'S CUSTOMER
create table CustomerAddress(
   c_id int not null,
   foreign key (c_id) references Customer(c_id),
   ad_number int check(ad_number >0 ) not null,
   ad_street nvarchar(40) not null,
   ad_district nvarchar(40) not null,
   ad_city nvarchar(40) not null,
)

--CREATE TABLE ORDER
create table [Order](
   o_id int identity(1, 1) primary key,
   c_id int not null,
   foreign key (c_id) references Customer(c_id),
   o_date date not null,
)


--CREATE ORDER DETAILS
create table OrderDetails (
    o_id int not null,
	p_id int not null,
	quantity int check (quantity > 0 ) not null,
    foreign key (o_id) references [Order](o_id),
	foreign key (p_id) references Product(p_id),
	primary key (o_id, p_id) 


)

--INSERT DATA PRODUCTION

--set identity_insert Production on;

insert into Product(p_name, p_desc, p_unit, p_price) values (N'Maý tính T450', N'Máy nhập mới', N'Chiếc', 1000);

insert into Product(p_name, p_desc, p_unit, p_price) values  (N'Điện thoại Nokia5670', N'Điện thoại đang hot', N'Chiếc', 200)

insert into Product(p_name, p_desc, p_unit, p_price) values (N'Máy in Samsung450', N'Máy in đang ế', N'Chiếc', 100)

insert into Product(p_name, p_desc, p_unit, p_price) values (N'Máy in Samsung550', N'Máy in đang chạy', N'Chiếc', 100)

insert into Product(p_name, p_desc, p_unit, p_price) values (N'Máy in Samsung850', N'Máy in đang ế', N'Chiếc', 100)


select * from Product

--INSERT data Customer

insert into Customer(c_name, c_phone) values (N'Nguyễn Văn An', '987654321')

select * from Customer



insert into CustomerAddress(c_id, ad_number, ad_street, ad_district, ad_city) values (2, 111, N'Nguyễn Trãi', N'Thanh Xuân', N'Hà Nội')

--INSERT ORDER
 set identity_insert [Order] on;

 insert into [Order](o_id, c_id, o_date) values (123, 2, '2009-11-08')


 --INSERT ORDER DETAILS

 insert into OrderDetails(o_id, p_id, quantity) values (123, 4, 1)
 insert into OrderDetails(o_id, p_id , quantity) values (123, 5, 2)
 insert into OrderDetails(o_id, p_id, quantity) values (123, 6, 1)
 go

 select * from product

 select * from OrderDetails

 --4: 
    --a: liệt kê danh sách khách hàng đã mua ở của hàng
	select * from Customer
	--b: liệt kê danh sách các sản phẩm của của hàng
	select * from product
	--c: liệt kê danh sách đơn đặt hàng của cửa hàng
	select * from [Order]

--5:
   
    select * from Customer order by c_name asc
	select * from Product order by p_price desc

	--sp mà khách hàng nguyễn văn an đã mua
	select p.* from Product as p 
	   inner join OrderDetails as od on  p.p_id = od.p_id
       inner join [Order] as o on o.o_id = od.o_id
	   inner join Customer as c on o.c_id = c.c_id 
    where c.c_name like N'Nguyễn Văn An'
	go

--6:
   --số kh đã mua ở cửa hàng
   select count(*) as Number_of_Customer 
   from Customer
   go

   --số mặt hàng mà của hàng bán
   select count(*) as Number_of_Product_Sold
   from Product
   where p_id in (select p_id from OrderDetails )
   go

   --tổng tiền từng đơn hàng

   select 
      o.o_id , sum(p.p_price * od.quantity) as 'Total Price'
	  
   from  
      [Order] as o inner join OrderDetails as od on o.o_id = od.o_id

	  inner join Product as p on od.p_id = p.p_id
	  
   group by o.o_id

--7: thay đổi những thông tin sau của dữ liệu
   -- giá tiền của từng mặt hàng là dương
   alter table Product
	    add constraint  CheckPrice check(p_price > 0) 

   insert into Product(p_name, p_desc, p_unit, p_price) values (N'Máy tính', 'aaaa', 'chiec', 0)
   go

   --ngày đặt hàng của khách hàng phaỉ nhỏ hơn ngày hiện tại

   alter table [Order]
      add constraint CheckDateOrder check (o_date <= day('2023-03-07'))
   go

   insert into [Order](c_id, o_date) values (2, '2024-01-01')

   --thêm trường ngày xuất hiện trên thị trường của Product
   alter table Product 
      add  Appear_Date date 
   go

   sp_rename 'Product.Appear_Date' , 'appear_date' , 'COLUMN'
   go

   
   select * from Product
    
 --8: 
  -- đặt index cho p_name, c_name tang tốc độ truy vấn trên các cột này
  create index IX_Product_Name
  on Product(p_name)


  create index IX_Customer_Name
  on Customer(c_name)

  --xây dựng các View

       -- view khách hàng vói các cột tên khách hàng, địa chỉ, điện thoại

	  
	   drop view if exists Customer_View
	   go
	   create view Customer_View
	   as
	   select
	      c.c_id, 
		  c_name,
		  c_phone,
		  cast(addr.ad_number as nvarchar) + ' ' + addr.ad_street + ' ' + addr.ad_district + ' ' + addr.ad_city as c_address 
      from 
	     Customer as c
		 inner join CustomerAddress as addr on c.c_id = addr.c_id
      go


     select * 
	 from Customer_View 
	 order by c_id



	   --view sản phầm với cac cột tân sản phầm, giá bán

	   drop view if exists Product_View
	   go
	   create view Product_View
	   as 
	   select 
	      p.p_name,
		  p.p_price
       from
	     Product as p
      go

	  select * from Product_View


	   --view khách hành sản phẩm với các cột: tên kh, số đt, tên sản phẩm, số lượng, ngày mua
	   drop view if exists Customer_Product_View 
	   go

	   create view CustomerProduct_View
	   as 
	   select
	       c.c_name as CustomerName,
		   c.c_phone as Phone,
		   p.p_name as ProductName,
		   od.quantity as Quantity, 
		   o.o_date as OrderDate
	   from 
	      Customer as c 

		  inner join [Order] as o on c.c_id = o.c_id
		  inner join OrderDetails as od on od.o_id = o.o_id
		  inner join Product as p on od.p_id = p.p_id
      go


	  select * from CustomerProduct_View

  --viết các thủ tục luu trữ: Stored Procedure

    -- SP_TimKH_MaKH: tìm khách hàng theo mã kh
	drop procedure if exists SelectCustomersByID 
	go

	create procedure SelectCustomersByID @ID int 
	as 
	select * from Customer where c_id=@ID
	go

	exec SelectCustomersByID @ID=2
	go

	--SP_Tim_KH_MaHD: tìm khách hàng theo mã hóa đơn
	drop procedure if exists SelectCustomersByOrderID
	go

	create procedure SelectCustomersByOrderID @O_ID int
	as
	select c.*
	from
	  Customer as c

      inner join [Order] as o on o.o_id =@O_ID and c.c_id = o.c_id
	    
    go

	exec SelectCustomersByOrderID @O_ID=123
	go

	--SP_SanPham_MaHK: liệt kê các sản phẩm được mua bởi KH co mã được truyền vào Store

	drop procedure if exists SelectProductsSoldByCustomerID 
	go

	create procedure SelectProductsSoldByCustomerID @C_ID int
	as
	select
	  p.*
    from
	  Product as p
	  inner join OrderDetails as od on od.p_id = p.p_id
	  inner join [Order] as o on  od.o_id = o.o_id
	  inner join Customer as c  on o.c_id = @C_ID
   go

   exec SelectProductsSoldByCustomerID @C_ID=2
   go