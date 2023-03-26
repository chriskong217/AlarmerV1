//
//  AlarmDetailView.swift
//  Alarmer Test
//
//  Created by user234729 on 3/26/23.
//

import SwiftUI

struct AlarmDetailView: View {
    var completion: (Alarm) -> Void
    
    var body: some View {
        Text("Alarm Detail View")
    }
}

struct AlarmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailView { _ in }
    }
}
