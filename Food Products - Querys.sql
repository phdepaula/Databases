Create database Produtos_Alimentícios;
Use Produtos_Alimentícios;

CREATE TABLE Mercadoria (
IDMercadoria int PRIMARY KEY auto_increment,
Produto VARCHAR (30) not null Unique,
Validade int
);

CREATE TABLE Pessoa (
IDPessoa int PRIMARY KEY auto_increment,
Responsável VARCHAR (30) not null Unique
);

CREATE TABLE Tipo (
IDTipo int PRIMARY KEY auto_increment,
Unidade VARCHAR (30) not null Unique
);

CREATE TABLE Estoque (
IDEstoque int PRIMARY KEY auto_increment,
Lote int Unique,
Fabricação date,
Quantidade int,
ID_Pessoa int,
ID_Tipo int,
ID_Mercadoria int,
FOREIGN KEY(ID_Pessoa) REFERENCES Pessoa (IDPessoa),
FOREIGN KEY(ID_Tipo) REFERENCES Tipo (IDTipo),
FOREIGN KEY(ID_Mercadoria) REFERENCES Mercadoria (IDMercadoria)
);

CREATE TABLE Histórico (
IDHistórico int PRIMARY KEY auto_increment,
Data_Atualizacao date not null,
ID_Pessoa int,
ID_Estoque int,
FOREIGN KEY(ID_Pessoa) REFERENCES Pessoa (IDPessoa),
FOREIGN KEY(ID_Estoque) REFERENCES Estoque (IDEstoque)
);


Insert into Mercadoria (Produto, Validade) values 
('Geleia', 30), ('Queijo', 15), 
('Linguiça', 120), 
('Doce de Leite', 10);

Insert into Tipo (Unidade) values
('Pote'), ('Peça'), ('Pacote');

Insert into Pessoa (Responsável) values
('José'), ('Maria');

delimiter $$
create procedure select_or_insert(
	in produto int,
    in lote int,
	IN pessoa int,
	IN quantidade int,
	IN fabricacao date,
	IN tipo int
)
begin
if exists(select * from Estoque where Estoque.ID_Mercadoria = produto and Estoque.Lote = lote)
THEN
update Estoque set 
	Quantidade = quantidade, 
	Fabricação = fabricacao
where Estoque.ID_Mercadoria = produto and Estoque.Lote = lote;
ELSE 
	insert into Estoque (Fabricação, Lote, Quantidade, ID_Pessoa, ID_Mercadoria, ID_Tipo)
    values (fabricacao, lote, quantidade, pessoa, produto, tipo);
END IF;
end $$

delimiter $$
create procedure remove_info(
	in lote_ID int
)
begin
if not exists(select * from Histórico
where Histórico.ID_Estoque = lote_ID) 	THEN
delete from Estoque Where Estoque.IDEstoque = lote_ID;
END IF;
end $$

Alter Table Estoque
Add Column Vencido boolean;

Insert into Estoque values (null, 57, '2022-10-25', 6, 1, 1, 1, True);
Insert into Estoque values (null, 154, '2022-11-01', 2, 1, 2, 2, True );
Insert into Estoque values (null, 63, '2022-11-04', 5, 1, 3, 3, False);
Insert into Estoque values (null, 58, '2022-11-07', 15, 1, 1, 1, False);
Insert into Estoque values (null, 89, '2022-11-13', 1, 2, 1, 4, True);
Insert into Estoque values (null, 155, '2022-11-15', 7, 2, 2, 2, False);
Insert into Estoque values (null, 156, '2022-11-23', 20, 1,2, 2, False);
Insert into Estoque values (null, 90, '2022-11-23', 30, 2, 1, 4, False);

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa;

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa
where E.Quantidade < 2;

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável, E.Vencido
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa
where E.Quantidade < 2;

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável, E.Vencido
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa
where P.Responsável = 'José';

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável, E.Vencido
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa
where (E.Fabricação >= "2022-10-25") and (E.Fabricação <= "2022-11-15");

Select M.Produto, E.Fabricação, M.Validade, date_add(E.Fabricação, interval M.Validade day) as Vencimento
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria;

Select M.Produto, E.Lote, E.Quantidade, T.Unidade, E.Fabricação, M.Validade, P.Responsável,
date_add(E.Fabricação, interval M.Validade day) as Vencimento
From Estoque E
Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
Inner Join Tipo T on E.ID_Tipo = T.IDTipo
Inner Join Pessoa p on E.ID_Pessoa = P.IDPessoa
where date_add(E.Fabricação, interval M.Validade day) < now();

Delimiter $$
create procedure verificar_flag(
	in new_status_vencimento boolean,
	in Estoque_ID int
)
begin
	IF not exists(Select M.Produto, E.Lote, E.Fabricação, M.Validade, E.Vencido
    From Estoque E
    Inner Join Mercadoria M on E.ID_Mercadoria = M.IDMercadoria
	where (date_add(E.Fabricação, interval M.Validade day) < now()) and (E.IDEstoque = Estoque_ID)
    and new_status_vencimento = True)
    THEN
		SIGNAL SQLSTATE '45000';
	END IF;
end $$

Delimiter $$
Create Trigger Atualizar_Flag
Before Update on Estoque
For each row
Begin
	if New.Vencido = True Then
		call verificar_flag(New.Vencido, OLD.IDEstoque);
    end if;
ENd$$




