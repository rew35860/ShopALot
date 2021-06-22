from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
from datetime import datetime


# Connecting to the database: code from DataStax Astra 
def connect_cassendra():
    cloud_config= {
        'secure_connect_bundle': "/Users/rew/Downloads/secure-connect-cs122d-spring.zip"
    }
    auth_provider = PlainTextAuthProvider('rsvrHPKpQDmYhjDjhBIISHJZ', 'ENo2M,rKX4ldlPzQv2h1SvhmZex9I1Ft7d+DISg952d18TfRhlinyhSSPuKMvm3ZLMzaXvULKpO0uWGn.LBAwn.BxuUqh8wOd86eOC8rEUPYQzHAoG.mg8E0WvL97T2h')
    cluster = Cluster(cloud=cloud_config, auth_provider=auth_provider)
    global session 
    session = cluster.connect()

    row = session.execute("select release_version from system.local").one()

    if row:
        print("SUCCESSFULLY CONNECTED!")
    else: 
        print("An error occurred.")


# Getting all table names and column names in a keyspace 
def get_tables(keyspace): 
    tables = dict()
    tempTables = session.execute(f"SELECT * FROM system_schema.tables WHERE keyspace_name = '{keyspace}';")

    for table in tempTables:
        tempColumns = session.execute(f"SELECT * FROM system_schema.columns WHERE keyspace_name = '{keyspace}' AND table_name = '{table.table_name}';")
        column = {i.column_name: 0 for i in tempColumns}
        tables[table.table_name] = column

    return tables


# Creating an insert command based on the argument dictionary 
def create_insert(tables, table_name, argDict):
    text = ""

    for column in tables[table_name]: 
        if column in argDict: 
            text += f"\"{column}\": \"{argDict[column]}\", "
        elif column in ["name", "category", "list_price"]:
            product_id = argDict["orderItems"][0]["product_id"]
            lookup = session.execute(f"SELECT {column} FROM \"ShopALot\".Products WHERE product_id = \'{product_id}\'")
            text += f"\"{column}\": \"{lookup.one()[0]}\", "
        elif column in ["item_id", "qty", "selling_price", "product_id"]:
            orderItem = argDict["orderItems"][0][column]
            text += f"\"{column}\": \"{orderItem}\", "

    text = f"INSERT INTO \"ShopALot\".{table_name} json '{{{text[:-2]}}}';"

    insert = session.prepare(text)
    results = session.execute(insert, argDict)


def insert_new_order(tables, infoDict):
    for table in tables:
        # Check if the input table needs to add new order 
        if "order_id" in tables[table]:
            create_insert(tables, table, infoDict) 


def main():
    keyspace = "ShopALot"
    connect_cassendra()
    new_order = {"order_id": "WEQ174", "total_price": 36.47, "time_placed": "2021-03-29T15:03:20.000Z", 
                "pickup_time": "2021-03-23T17:54:21.000Z", "customer_id": "6Z53Z", "shopper_id": "MQD30", 
                "state": "WV", "license_plate": "0031", "store_id": "ZU9IP", "time_fulfilled": "2021-03-23T22:43:12.000Z", 
                "orderItems": [{"item_id": "PO12C", "qty": "7", "selling_price": 5.21, "product_id": "GMGO5"}]}
    
    tables = get_tables(keyspace)
    insert_new_order(tables, new_order)


if __name__ == "__main__":
    main(); 



    

