//
//  Home.swift
//  SwiftUIPullToRefresh
//
//  Created by 张亚飞 on 2021/6/16.
//

import SwiftUI

struct Home: View {
    
    @State var count: Int = 3
    
    var body: some View {
        
        NavigationView {
            
            RefreshableScrollView(content: {
                
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3) , spacing: 2) {

                    ForEach(1..<count, id:\.self) { index in

//                        Color.red
//                            .frame(height: 183)
//                            .overlay(
//                                Text("\(index)")
//                                    .font(.largeTitle)
//                            )
//                            .onTapGesture {
//                                count += 2
//                            }
                        
                        GeometryReader { proxy in
                            
                            let width = proxy.frame(in: .global).width
                            
                            Image("p\(count - index)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:width, height:183)
                                .cornerRadius(1)
                            
                        }
                        .frame(height: 183)
                        
                    }
                }
                .padding()
                
            }, onRefresh: { control in
                
                //refresh content...
                // do what ever update...
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    count = self.count + 3 > 13 ? 13 : self.count + 3
                    control.endRefreshing()
                }
                
            })
            .navigationTitle("Pull Me Down")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


// custom scrollview with refresh control
struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    
    var content: Content
    var onRefresh: (UIRefreshControl) -> ()
    var refreshControl = UIRefreshControl()
    
    //view builder to capture swiftUI view...
    init(@ViewBuilder content: @escaping()-> Content, onRefresh: @escaping(UIRefreshControl) -> ()) {
        
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(parent: self)
        
    
    }
    
    
    func makeUIView(context: Context) -> UIScrollView {
        
        let uiscrollView = UIScrollView()
        uiscrollView.delegate = context.coordinator
        
        // refresh control...
        refreshControl.attributedTitle = NSAttributedString(string: "Pull Me")
        refreshControl.tintColor = .red
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.onRefresh), for: .valueChanged)
        
        
        setUpView(uiscrollView: uiscrollView)
        
        //since were removing the last subview
        //so ite will remove refresh control
        //so add after seting up view...
        uiscrollView.refreshControl = refreshControl
        
        return uiscrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
        //because view is not updating dynamiclly...
        //updating view dynamically
        
        setUpView(uiscrollView: uiView)
        
    }
    
    func setUpView(uiscrollView: UIScrollView) {
        
        //extracting swiftui view...
        let hostView = UIHostingController(rootView: content.frame(maxHeight: .infinity, alignment: .top))
        
        //were going to constraints system from uikit
        //so that no need of width and height calculations...
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let  constraints = [
            
            hostView.view.topAnchor.constraint(equalTo: uiscrollView.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: uiscrollView.bottomAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: uiscrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: uiscrollView.trailingAnchor),
            
            hostView.view.heightAnchor.constraint(greaterThanOrEqualTo: uiscrollView.heightAnchor),
            // for bouncing...
            hostView.view.widthAnchor.constraint(equalTo: uiscrollView.widthAnchor, constant: 1),
            
        ]
        
        //removing previously added view...
        uiscrollView.subviews.last?.removeFromSuperview()
        uiscrollView.addSubview(hostView.view)
        uiscrollView.addConstraints(constraints)
        
    }
    
    
    class Coordinator: NSObject, UIScrollViewDelegate{
        
        var parent: RefreshableScrollView
        
        init(parent: RefreshableScrollView) {
            
            self.parent = parent
        }
        
        @objc func onRefresh() {
            
            parent.onRefresh(parent.refreshControl)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {

            scrollView.contentOffset.x = 0.0
        }
    }
}
