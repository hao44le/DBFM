//
//  ViewController.swift
//  DBFM
//
//  Created by Gelei Chen on 12/18/14.
//  Copyright (c) 2014 Purdue iOS Club. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if sender.view==btnPlay{
            btnPlay.hidden=true
            audioPlayer.play()
            btnPlay.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        } else if sender.view == iv {
            btnPlay.hidden=false
            audioPlayer.pause()
            btnPlay.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
            
        }
    }
    @IBOutlet weak var btnPlay: UIImageView!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playTime: UILabel!
    var eHttp:HttpController = HttpController()
    var tableData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    var imageCache = Dictionary<String,UIImage>()
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController()
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        progressView.progress=0.0
        iv.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let rowData:NSDictionary=self.tableData[indexPath.row] as NSDictionary
        let audioUrl:String=rowData["url"] as String
        onSetAudio(audioUrl)
        let imgUrl:String=rowData["picture"] as String
//        onSetImage(imgUrl)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelC:ChannelController=segue.destinationViewController as ChannelController
        channelC.delegate=self
        channelC.channelData=self.channelData
        
    }
    func onChangeChannel(channel_id: String) {
        let url:String="http://douban.fm/j/mine/playlist?\(channel_id)"
        
        eHttp.onSearch(url)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform=CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform=CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func didRecieveResults(results:NSDictionary){
        if (results["song"] != nil){
            self.tableData = results["song"] as NSArray
            self.tv.reloadData()
            let firDict:NSDictionary=self.tableData[0] as NSDictionary
            let audioUrl:String = firDict["url"] as String
            onSetAudio(audioUrl)
            let imgUrl:String=firDict["picture"] as String
 //           onSetImage(imgUrl)
            
            
            
        } else if (results["channels"] != nil){
            self.channelData = results["channels"] as NSArray
            
        }
    }
    
    func onSetAudio(url:String){
        timer?.invalidate()
        playTime.text="00:00"
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL=NSURL(string:url)
        self.audioPlayer.play()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.removeGestureRecognizer(tap)
        iv.addGestureRecognizer(tap)
        btnPlay.hidden=true
        
    }
    func onUpdate(){
        let c=audioPlayer.currentPlaybackTime
        if c>0.0{
            let t=audioPlayer.duration
            let p:CFloat=CFloat(c/t)
            progressView.setProgress(p, animated: true)
            let all:Int=Int(c)
            let m:Int=all % 60
            let f:Int = Int(all/60)
            var time:String=""
            if f < 10 {
                time = "0\(f):"
            } else {
                time = "\(f):"
            }
            
            if m < 10 {
                time += "0\(m)"
            } else {
                time += "\(m)"
            }
            playTime.text=time
            
        }
        
    }
//    func onSetImage(url:String){
//        let image = self.imageCache[url]
//        if (image != nil){
//            let imgURL:NSURL=NSURL(string:url)!
//            let request:NSURLRequest=NSURLRequest(URL:imgURL)
//            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
//                let img = UIImage(data:data)
//                self.iv.image=img
//                self.imageCache[url]=img
//            })
//        } else {
//            self.iv.image = image
//        }
//
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableData.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        cell.textLabel?.text = rowData["title"] as? String
        
        cell.detailTextLabel?.text=rowData["artist"] as? String
        
        cell.imageView?.image = UIImage(named:"2cd888c75895ffe6ac8b7dd7ca4e1731.png")
        
//        let url = rowData["picture"] as String
//        let image = self.imageCache[url]
//        if (image != nil){
//            let imgURL:NSURL=NSURL(string:url)!
//            let request:NSURLRequest=NSURLRequest(URL:imgURL)
//            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
//                cell.imageView?.image = UIImage(data:data)
//                self.imageCache[url] = UIImage(data:data)
//                })
//        } else {
//           cell.imageView?.image = image
//       }
        
        return cell

    }

}
