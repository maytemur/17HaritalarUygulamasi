//
//  ViewController.swift
//  17HaritalarUygulamasi
//
//  Created by maytemur on 27.12.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var isimTextField: UITextField!
    
    @IBOutlet weak var notTextField: UITextField!
    
    @IBOutlet weak var haritaGoruntusu: MKMapView!

    var locationManager = CLLocationManager()
    
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    //kayıt yapma ve bunu listeleme işini bitirdik artık kayıtlar içinden secilen isim ve id'sini almamız gerekiyorki bununla 2nci ekrana gidebilelim
    var secilenIsim = ""
    var secilenId: UUID?
    
    //core data'dan çektiğimiz değerleri değişkenlere atayalım ki heryerden bunlara ulaşabilelim
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        haritaGoruntusu.delegate = self
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //en yakın kimotere ,en iyi gps verisine göre,düşürülmüş az yakan gps gibi seçenekleri mevcut. En çok batarya yesede biz burda besti seçtik
        locationManager.requestWhenInUseAuthorization() //adamı takip etmek için izin almamız lazım. Eğer always takip dersek adam kabul edecek olsa bile eğer gerekmiyorsa appstore'a koyduğumuzda apple bize sorun çıkartır gerek yok neden istiyorsun diye. Sadece kullanıldığında olacak şekilde istedik
        locationManager.startUpdatingLocation() //konumu güncellemeye başla!
        //adamın neden konumunu aldığımızı info.plist dosyasında anahtar ekleyerek bildirmemiz gerekiyor bunu Privacy - Location When In Use Usage Description ve açıklamasınada neden ihtiyaç duyulduğunu yazarak yaptık
        
        //haritaya tıklamayı alalım . Bunuda yine gesture ile yapacağız ama uzun basmayı alıcaz
        let gestureAl = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureAl:)) )
        gestureAl.minimumPressDuration = 2 //uzun basma süresi 3sn dedik-3 çok uzun 2 yaptım
        haritaGoruntusu.addGestureRecognizer(gestureAl)
        
        if secilenIsim != "" {
            //core data'dan verileri çek
                        
            if let uuidMetni = secilenId?.uuidString{
//                print("ID değeri : "+uuidMetni)
                let appDelegateYapisi = UIApplication.shared.delegate as!AppDelegate
                let contextYapisi = appDelegateYapisi.persistentContainer.viewContext
                
                let fetchRequestDegeri = NSFetchRequest<NSFetchRequestResult>(entityName: "Lokasyon")
                fetchRequestDegeri.predicate = NSPredicate(format: "id = %@", uuidMetni)
                fetchRequestDegeri.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try contextYapisi.fetch(fetchRequestDegeri)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                annotationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            haritaGoruntusu.addAnnotation(annotation)
                                            isimTextField.text = annotationTitle
                                            notTextField.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9)
                                            //0.9 zoom daha iyi daha yukarıdan
                                            let region = MKCoordinateRegion(center: coordinate, span:  span)

                                            haritaGoruntusu.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                    }
                       
                    }
                } catch  {
                    print("hata")
                }
            }
        }else{
            //yeni veri eklemeye geldi
        }
        }
    
    
    //konumu aldık şimdi ne yapacağız? bunun için bir hazır fonksiyon var didupdatelocations yazdığımızda otomatik çıkıyor locationManager isminde onu alıyoruz ama burada ben delegate olarak class ismini locationManager olarak türkçesini yazdığımdan o ismi değiştirmek zorundayım
    //locationManager isminden farklı (konumYoneticisi mesela) isminin verilmesine hata vermiyor ama çalışmıyorda! bu yüzden locationManager ismi vermek zorundayım en azından şimdilik böyle!

    func locationManager (_ manager: CLLocationManager, didUpdateLocations
                         locations: [CLLocation]) {
        
//        print(locations[0].coordinate.latitude)
//        print(locations[0].coordinate.longitude)
        //artık anlık olarak gps verileri geliyor print ediyor,bunları aldık ama bunları ne yapıcaz?
 
        //kayıtlı bir noktaya gidiliyorsa bu anlık update işlemini yapmasın diye koşul ekledik sonradan
        if secilenIsim == "" {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //harita görüntüsünü değiştirmek için setRegion kullanıyoruz ,region bizden 2 şey istiyor span (yani zoom şimdilik 0.1 verdik deneyeceğiz) ve region yani sondan başladık bir nevi!
        
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let span = MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9)
        //0.9 zoom daha iyi daha yukarıdan
        let region = MKCoordinateRegion(center: location, span:  span)
        
        haritaGoruntusu.setRegion(region, animated: true)
            
        }
        //şu an verdiğimiz custom location ile vs simulator üzerinden istediğimiz yere haritayı götürebiliyoruz ama henüz tıklayarak hedefe gitme vs yapmadık onu yapacağız
            
    }
    
    @objc func konumSec(gestureAl : UILongPressGestureRecognizer){
        if gestureAl.state == .began {
            let dokunulanNokta = gestureAl.location(in: haritaGoruntusu)
            let dokunulanKoordinat = haritaGoruntusu.convert(dokunulanNokta, toCoordinateFrom: haritaGoruntusu)
            //işaretleme terimi annotation diye geçiyor bunu anlamamız gerekiyor dedi! bu yüzden bu terimi kullanıyoruz
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
//            annotation.title = "Kullanıcı Seçimi"
            annotation.title = isimTextField.text
//            annotation.subtitle = "Örnek Altyazı"
            annotation.subtitle = notTextField.text
            haritaGoruntusu.addAnnotation(annotation)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
        }
    }
    
    
    @IBAction func KaydetTiklandi(_ sender: Any) {
        //önce context'e ulaşmaya çalışıcaz sonra modelimiz belli,insert diyerek ekleyeceğiz sonrada yine context ile kaydedeceğiz. Birde unutmadan yukarıda import coredata yapmamız gerekiyor
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Lokasyon", into: context)
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        //enlem boylamı almak için yukarıda 2 tane değişken tanımlamamız gerekiyor. Onlarla konumsec'teki konumları alabiliriz
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("kayıt edildi")
        } catch {
            print("hata")
        }
        
        //verileri kayıt ettik ama bunları yükleyip kullanıcıya göstermemiz gerekiyor
        //kullanıcı arayüzü yapıyoruz
        //kayıt işlemi olduktan sonra bu ekrandan ilk ekrana dönmemiz gerekiyor bunu yapmak için bir notification oluşturup bunuda diğer bir yerden gözlemleyerek halledicez. Bu sebeple burada bir NotificationCenter oluşturuyoruz
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yeniYerOlusturuldu") , object: nil)
        //navigation controller ile geri döndürelim-->ListViewController'a gittik ve burada viewWillAppear ile gözlemleme işini yapıp veri listesini güncelleyeceğiz
        navigationController?.popViewController(animated: true)
    }
    
    //Çaktığımız iğneleri(annotation) özelleştirmek istiyoruz. Bunu iğneye tıkladığımızda bize route yol haritasını versin oraya götürsün şeklinde bir program istediğimiz için yapmamız gerek
    //başka türlü kullanımlar programın geliştirilmesi vs içinde bunu öğrenmemiz gerek
    //bunun için viewFor annotation diye bir hazır metod var onu kullanıcaz
    //bunu yazdıktan sonra iğnenin şekli değişiyor ve üstüne tıkladığımızda bir i adında buton çıkıyor
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //kullanıcının kendisini gösteren annotation ise buna karışmıyoruz konubuysa buna return nil diyoruz
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "caktigimizAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //yani yanında buton vs gösterebilirmiyiz true dedik
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    //Navigasyon
    //Navigasyon kısmı için annotationView metodunu kullanıyoruz
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) {
                (placemarkDizisi, hata) in
                if let placemarks = placemarkDizisi {
                if placemarks.count > 0 {
                    let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                    let item = MKMapItem(placemark: yeniPlacemark)
                    item.name = self.annotationTitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
         }
       }
    }
 }
