import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:bandnames/models/band.dart';
import 'package:bandnames/services/socket.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _activeBandsMethod = 'active-bands';

  List<Band> bands = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final SocketService socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.on(_activeBandsMethod, _handleActiveBands);
    });
  }

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child:
              socketService.serverStatus == ServerStatus.online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red[300])
          )
        ],
      ),
      body: Column(
        children: [
          // Show graph
          _showGraph(),
          // Band names
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile( bands[i] )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: Icon(Icons.add)
      ),
   );
  }

  @override
  void dispose() {
    final SocketService socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off(_activeBandsMethod);
    
    super.dispose();
  }

  // Functions
  Widget _bandTile( Band band ) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id ?? ""),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', { 'id': band.id })
      ,
      background: Container(
        padding: EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white) ),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name!.substring(0,2)),
        ),
        title: Text( band.name ?? "" ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20) ),
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();
    
    if(Platform.isAndroid) {
      // Android
      return showDialog(
        context: context,
        builder: (_) =>
          AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text ),
                child: Text('Add')
              )
            ]
          )
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) => CupertinoAlertDialog(
        title: Text('New band name:'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Add'),
            onPressed: () => addBandToList( textController.text )
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context)
          )
        ],
      )
    );
  }  

  void addBandToList( String name ) {
    
    if(name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      
      socketService.socket.emit('add-band', {
        'name': name
      });  
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    if(bands.isEmpty) {
      return Container();
    }
    else {
      Map<String, double> dataMap = {};

      bands.forEach((band) {
        dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble() );
      });

      final List<Color> colorList = [
        Colors.blue[200]!,
        Colors.blue[400]!,
        Colors.pink[200]!,
        Colors.pink[400]!,
        Colors.yellow[200]!,
        Colors.yellow[400]!,
      ];

      return Container(
        padding: EdgeInsets.only(top: 0),
        width: double.infinity,
        height: 300,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 64,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
          
        )
      );
    }
  }

  // Listeners
  void _handleActiveBands(dynamic payload) {
    if (!mounted) return;

    bands = (payload as List)
      .map( (band) => Band.fromMap(band) )
      .toList();

    setState(() {});
  }

}