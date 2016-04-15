import js.node.Fs;
import js.Node;
import js.Node.*;
import js.npm.Async.*;
import js.npm.sequelize.Sequelize;
import yaml.Yaml;
import yaml.Parser;
import yaml.Renderer;
import yaml.util.ObjectMap;

class Main {
    public static function getForeignKeysQuery(tableName, schemaName) {
        return 'SELECT 
            ccu.table_name AS source_table 
            ,ccu.constraint_name AS constraint_name 
            ,ccu.column_name AS source_column 
            ,kcu.table_name AS target_table 
            ,kcu.column_name AS target_column 
          FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu 
          INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc 
              ON ccu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME 
          INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu  
              ON kcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME 
              WHERE ccu.table_name = ' + untyped __js__("js_npm_sequelize_Sequelize.Utils.addTicks(tableName, \"'\")");
      }

    public static function loadConfiguration(pEnvFile : String) : Dynamic {
        trace('setting env file to : '+pEnvFile);
        
        var confPath = pEnvFile;
        var confFile = Fs.readFileSync(confPath, 'utf8');
        return Yaml.parse(confFile);
    }

      public static function initDb (conf : Dynamic) {

        var dbOpts = conf.get('DB_OPTIONS');
        var poolOpts = dbOpts.get('pool');
        var dialectOps = dbOpts.get('dialectOptions');
        var opts = {
            host: dbOpts.get('host'),
            dialect: dbOpts.get('dialect'),
            storage: dbOpts.get('storage'),
            pool: {
              max: poolOpts.get('max'),
              min: poolOpts.get('min'),
              idle: poolOpts.get('idle')
            },
            dialectOptions: {
              encrypt: dialectOps.get('encrypt')
            },
            logging: dbOpts.get('logging')
          };
        return new Sequelize(conf.get('DB_NAME'), conf.get('DB_USER'), conf.get('DB_PASSWORD'), untyped opts);
      }

    static function main() {
        var async    = Node.require('async');

        if( Reflect.hasField(process.env,'output') && 
            Reflect.field(process.env,'output') != '' && 
            Reflect.hasField(process.env,'conf') && 
            Reflect.field(process.env,'conf') != '') {


                var conf = loadConfiguration(Reflect.field(process.env,'conf'));
                
                var db = initDb(conf);
                
                var qi = untyped __js__("db.getQueryInterface()");

                trace(untyped __js__('db.options.dialect'));


                untyped __js__("qi.showAllTables().then(function (t) { 

                        if(db.options.dialect == 'mssql') t = js_npm_sequelize_Sequelize.Utils._.map(t, 'tableName');

                        async.each(t, mapForeignKeys, mapTables);

                });");


        }
        else
            trace('missing one or more parameters ( usage : conf=[conf_filename] output=[output_folder] ./run.sh ) ');
    }
}
