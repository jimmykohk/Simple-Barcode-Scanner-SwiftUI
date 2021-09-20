//
//  ContentView.swift
//  Barcode Scanner
//
//  Created by Jimmy on 20/9/2021.
//

import SwiftUI

struct ContentView: View {
    @State var barcodeString: String = ""
    var body: some View {
        NavigationView{
            VStack{
                if (barcodeString.isEmpty){
                    Text("Please scan the barcode first")
                }else{
                    Text("Barcode: \(barcodeString)")
                }
                NavigationLink(
                    destination:
                        CameraView(barcode: $barcodeString),
                    label: {
                        HStack(spacing: 8.0){
                            Image(systemName: "camera")
                            Text("Scan")
                        }
                    })
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
