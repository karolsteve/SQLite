# SQLite
Wrapper around C SQLite interface that allows you to use SQLite in iOS as on Android with a little change
## How it's work
Just Add theses files to your project. see below section for how to use
## Example
```Swift
class DbHelper : SQLiteOpenHelper {
    
    convenience init(){
        let version = 1
        let dbName = "test.db"
        self.init(version, dbName)
    }

    //Call when database is created
    func onCreate(database : SQLiteDatabase){
        database.exec("CREATE TABLE test...") //Create tables and add triggers 
    }
    
    //Call when database is upgraded
    func onUpgrade(database : SQLiteDatabase){
        database.exec("ALTER TABLE ...")
    }
    
    //Call when database is downgraded
    func onDowngrade(database : SQLiteDatabase){
        fatalError("Downgrade not supported")
    }
}
```
