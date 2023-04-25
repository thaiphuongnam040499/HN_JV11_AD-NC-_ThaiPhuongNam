create database QLBH_ThaiPhuongNam;
use QLBH_ThaiPhuongNam;
create table Customer(
cId int primary key,
`Name` varchar(25),
cAge tinyint
);

create table `Order`(
oId int primary key,
cId int,
foreign key (cId) references Customer(cId),
oDate datetime,
oTotalPrice int
);

create table Product(
pId int primary key,
pName varchar(25),
pPrice int
); 

create table OrderDetail(
oId int,
foreign key (oId)references `Order`(oId),
pId int,
foreign key (pId) references Product(pId),
odQTY int 
);

insert into Customer values 
(1,"Minh Quan", 10),
(2,"Ngoc Oanh", 20),
(3,"Hong Ha", 50);

insert into `Order` values
(1,1,"2006-3-21",null),
(2,2,"2006-3-23",null),
(3,1,"2006-3-16",null);

insert into Product values 
(1,"May giat",3),
(2,"Tu lanh",5),
(3,"Dieu hoa",7),
(4,"Quat",1),
(5,"Bep Dien",2);

insert into OrderDetail values
(1,1,3),
(1,3,7),
(1,4,2),
(2,1,1),
(3,1,8),
(2,5,4),
(2,3,3);

-- 2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
-- trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
-- đơn mới hơn nằm trên
select o.oId,c.cId, o.oDate, o.oTotalPrice from `Order` o join Customer c on o.cId = c.cId order by day(o.oDate) desc;
-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất như sau:
select p.pName, p.pPrice from Product p where p.pPrice = (select max(pPrice) from Product);
-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản
-- phẩm được mua bởi các khách đó như sau
select c.`name`, p.pName from Customer c join `Order` o on c.cId = o.cId 
join OrderDetail od on o.oId = od.oId join Product p on od.pId= p.pId;
-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
select c.`name` from Customer c where c.`name` 
not in (select c.`name` from Customer c join `Order` o on c.cId = o.cId);
-- 6. Hiển thị chi tiết của từng hóa đơn
select o.oId, o.oDate, od.odQTY , pName, pPrice from `Order` o 
join OrderDetail od on o.oId = od.oId join Product p on p.pId = od.pId;
-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một
-- hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện
-- trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice) 
select o.oId, o.oDate, sum(od.odQTY * p.pPrice) as Total from `Order` o join OrderDetail od on o.oId = od.oId 
join Product p on od.pId = p.pId group by o.oId;
-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị
select sum(Total) as Sales from (select o.oId, o.oDate, sum(od.odQTY * p.pPrice) as Total from `Order` o join OrderDetail od on o.oId = od.oId 
join Product p on od.pId = p.pId group by o.oId) as Total;
-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng
alter table `Order`
drop foreign key order_ibfk_1;
alter table OrderDetail
drop foreign key orderdetail_ibfk_1,
drop foreign key orderdetail_ibfk_2;
-- xóa khóa chính
alter table Customer
drop primary key;
alter table `Order`
drop primary key;
alter table Product
drop primary key;
-- 10 Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
-- mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo
create trigger cusUpdate
after update on Customer
for each row
update `Order` set cID = new.cID where cID = old.cID;
update Customer
set cId = 4 where cId = 1;
-- 11. Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của
-- một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên
-- vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong
-- bảng OrderDetail
DELIMITER // 
create procedure delProduct(in pNameDel varchar(25))
begin
delete from Product where pName = pNameDel;
delete from OrderDetail where pId = (select pId from Product where pName = pNameDel);
end //
DELIMITER ;
call delProduct("Bep Dien");
-- nếu gặp lỗi 1451 thì sử dụng hai câu lệnh này
-- SET SQL_SAFE_UPDATES = 0;
-- SET foreign_key_checks = 0;