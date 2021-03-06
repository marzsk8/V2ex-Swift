//
//  NodeModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji

class NodeModel: NSObject ,BaseHtmlModelProtocol{
    var nodeId:String?
    var nodeName:String?
    var width:CGFloat = 0
    override init() {
        super.init()
    }
    required init(rootNode: JiNode) {
        self.nodeName = rootNode.content
        if let nodeName = self.nodeName {
            //计算字符串所占的宽度
            //用于之后这个 node 在 cell 中所占的宽度
            let rect = (nodeName as NSString).boundingRect(
                with: CGSize(width: SCREEN_WIDTH,height: 15),
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedStringKey.font:v2Font(15)], context: nil)
            
            self.width = rect.width;
        }
        
        if var href = rootNode["href"] {
            if let range = href.range(of: "/go/") {
                href.replaceSubrange(range, with: "");
                self.nodeId = href
            }
        }
    }
}
class NodeGroupModel: NSObject ,BaseHtmlModelProtocol{
    var groupName:String?
    var childrenRows:[[Int]] = [[]]
    var children:[NodeModel] = []
    required init(rootNode: JiNode) {
        self.groupName = rootNode.xPath("./td[1]/span").first?.content
        for node in rootNode.xPath("./td[2]/a") {
            self.children.append(NodeModel(rootNode: node))
        }
    }
    
    class func getNodes( _ completionHandler: ((V2ValueResponse<[NodeGroupModel]>) -> Void)? = nil ) {
        Alamofire.request(V2EXURL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) in
            var groupArray : [NodeGroupModel] = []
            if let jiHtml = response .result.value{
                if let nodes = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][last()]/div/table/tr") {
                    for rootNode in nodes {
                        let group = NodeGroupModel(rootNode: rootNode)
                        groupArray.append(group)
                    }
                }
                completionHandler?(V2ValueResponse(value: groupArray, success: true))
                return;
            }
            completionHandler?(V2ValueResponse(success: false, message: "获取失败"))
        }
    }
    
}
