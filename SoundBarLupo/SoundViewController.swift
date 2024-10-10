import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombretxt: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var Tirmpolbl: UILabel!
    @IBOutlet weak var controlSonido: UISlider!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?
    var seconds: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }

    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("*********************")
            print(audioURL!)
            print("*********************")
            
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            timer?.invalidate()
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
            agregarButton.isEnabled = false
            seconds = 0
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds += 1
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secondsDisplay = (seconds % 3600) % 60
        Tirmpolbl.text = String(format: "%02d:%02d:%02d", hours, minutes, secondsDisplay)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.volume = controlSonido.value
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }

    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombretxt.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.time = Tirmpolbl.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
 
    @IBAction func controlVolumenCambiado(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }
    
}
