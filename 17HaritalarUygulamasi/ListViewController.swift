//
//  ListViewController.swift
//  17HaritalarUygulamasi
//
//  Created by maytemur on 2.01.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //isimleri coredata 'dan aldıktan sonra bir listeye kaydetmekde fayda var dedi!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    //artık verileri kayıt ettik listemiz var ,oradan gelecek verilerle core data'dan verileri çekip gösterememiz gerekiyor
    var kayitliYerAdi = ""
    var kayitliYerId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //bar da + işareti çıkmaası için
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButonuTiklandi))
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5 artık 5 tane değil aldığımız veri sayısınca döndürücez bunuda isimlistesi veya iddizisi count ile alabiliriz
        return isimDizisi.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
//        cell.textLabel?.text = "test" artık test değil isimdizisi row'undan gelen değeri yazdırıcaz
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    @objc func veriAl(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lokasyon")
        request.returnsObjectsAsFaults = false
        
        do {
            let sonuclar = try context.fetch(request)
            
            if sonuclar.count>0 {
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                //yeni veri geldi diye table'ı yeniliyoruz
                tableView.reloadData()
            }
        } catch  {
            print("hata")
        }
        
    }
    
    
    @objc func artiButonuTiklandi(){
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
        //artı butonu ile mapsview controller'a gittiğinde bu değişkeni boş gönderelimki kayıt etmeye gittiği belli olsun
        kayitliYerAdi = ""
    }
    //onun yaptığı gibi viewdidLoad'da değil viewDidAppear da veriAl'ı çalıştırdığım için aslında böyle bir gözlemleme(Observer) ve notification çalıştırma olayına girmem gereksiz ama yinede örnek olması açısından notification çalıştığında viewDidAppear zaten olacak olan veriAl foknsiyonunu çalıştıracağım bunu yapabilmek için veriAl fonksiyonun başına @objc paremetresini ekledik
    //veriAl() fonksiyonunun başına @objc parametresini eklemek önceki işleyişini değiştirmedi
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        veriAl()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kayitliYerAdi = isimDizisi[indexPath.row]
        kayitliYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            //burada segue'yi mapsviewcontroller olarak cast ettik as ile! artık oradaki değişkenlere erişebiliriz
            destinationVC.secilenIsim = kayitliYerAdi
            destinationVC.secilenId = kayitliYerId
        }
    }

}
