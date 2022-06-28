create database hepsiburada

create table urunler(
barkodid int primary key,
urunadi nvarchar(50),
miktar int,
fiyat int,
toplam int)

create table sepet(
sepet_id int primary key,
barkodid int foreign key references urunler(barkodid),
miktar int,
fiyat int,
toplamfiyat int)

create table satis(
satis_id int primary key,
barkodid int foreign key references urunler(barkodid),
miktari int,
fiyat int,
toplam int)

--�r�nler tablosunun toplam fiyat�n� hesaplama
create trigger urunler_toplam_fiyat
on urunler
after insert
as
begin
update urunler set toplam=miktar*fiyat
end

--Sepet tablosunun fiyat�n� �r�nler tablosundan �ekme
create trigger sepet_fiyat_cekme
on sepet
after insert
as
begin
declare @barkodid int, @fiyat int
select @barkodid=barkodid from inserted
select @fiyat=(select fiyat from urunler where barkodid=@barkodid)
update sepet set fiyat=@fiyat where barkodid=@barkodid
end

--Sepet tablosunun toplam fiyat�n� hesaplama
create trigger sepet_toplam_fiyat
on sepet
after insert
as
begin
update sepet set toplamfiyat=miktar*fiyat
end

--Sepet tablosuna �r�n eklendi�inde �r�nler tablosundan �r�n eksiltme
create trigger urun_eksiltme
on sepet
after insert
as
declare @barkodid int, @miktar int
select @barkodid=barkodid, @miktar=miktar from inserted
update urunler set miktar=miktar-@miktar where barkodid=@barkodid
update urunler set toplam=toplam-@miktar*fiyat where barkodid=@barkodid

--Sepet tablosundan �r�n silindi�inde sat�� tablosuna �r�n ekleme
create trigger satis_ekleme
on sepet
after delete
as
declare @barkodid int, @miktar int, @fiyat int
select @barkodid=barkodid, @miktar=miktar, @fiyat=fiyat from deleted
insert into satis (satis_id, barkodid, miktari, fiyat, toplam)
values (1,@barkodid,@miktar,@fiyat,@miktar*@fiyat)

--Sepet tablosundan �r�n g�ncellendi�inde �r�n tablosunu g�ncelleme
create trigger sepet_guncelleme
on sepet
after update 
as
begin
declare @barkodid int, @eskimiktar int, @yenimiktar int
select @barkodid=barkodid, @eskimiktar=miktar from deleted
select @barkodid=barkodid, @yenimiktar=miktar from inserted
update urunler set miktar=miktar-(@yenimiktar-@eskimiktar)
where @barkodid=barkodid
end

-- �r�nler tablosuna bir �r�n eklendi�inde eklenen �r�n� ekrana yazd�rma
create trigger eklenen_urun_yazdirma
on urunler
after insert
as
begin
select * from inserted
end

insert into urunler values(5,'ekran kart�',10,3500,35000)

--Bir �r�n sat��� oldu�unda, sat�lan �r�n�n 
--barkod numaras�n�, ka� adet sat�ld���n�, hangi tarihte ve kim taraf�ndan sat�ld���n� ba�ka bir tabloya kay�t etme
create trigger kayit_tutma
on satis
after delete
as
begin
declare @barkodid int, @miktar int
select @barkodid=barkodid, @miktar=miktari from deleted
insert into kayitlar values('Barkod Numaras� '+
cast(@barkodid as nvarchar(50))+' olan �r�nden '+
cast(@miktar as nvarchar(50))+' adet '+ SUSER_NAME()+' kullan�c�s� taraf�ndan ' +
cast(getdate() as nvarchar(50))+' tarihinde sat�lm��t�r.')
end

